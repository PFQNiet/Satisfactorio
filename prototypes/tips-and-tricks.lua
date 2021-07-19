-- TODO Make real tips-and-tricks
-- For now, just wipe all the Vanilla ones and say "hey you're supposed to know how Factorio works if you're playing overhaul mods"
local vanilla_tiptrick_categories = {
	"belts", "copy-paste", "drag-building", "electric-network", "fast-replace",
	"game-interaction", "ghost-building", "inserters", "logistic-network", "trains"
}
local vanilla_tiptrick_items = {
	"active-provider-chest", "belt-lanes", "buffer-chest", "bulk-crafting", "burner-inserter-refueling", "circuit-network", "clear-cursor",
	"connect-switch", "construction-robots", "copy-entity-settings", "copy-paste", "copy-paste-filters", "copy-paste-requester-chest",
	"copy-paste-spidertron", "copy-paste-trains", "drag-building", "drag-building-poles", "drag-building-underground-belts", "e-confirm",
	"electric-network", "electric-pole-connections", "entity-transfers", "fast-belt-bending", "fast-obstacle-traversing", "fast-replace",
	"fast-replace-belt-splitter", "fast-replace-belt-underground", "fast-replace-direction", "gate-over-rail", "ghost-building",
	"ghost-rail-planner", "inserters", "insertion-limits", "introduction", "limit-chests", "logistic-network", "long-handed-inserters",
	"low-power", "move-between-labs", "passive-provider-chest", "personal-logistics", "pipette", "pump-connection", "rail-building",
	"rail-signals-advanced", "rail-signals-basic", "requester-chest", "rotating-assemblers", "shoot-targeting", "show-info",
	"splitter-filters", "splitters", "stack-transfers", "steam-power", "storage-chest", "train-stop-same-name", "train-stops",
	"trains", "transport-belts", "underground-belts", "z-dropping"
}
for _,name in pairs(vanilla_tiptrick_categories) do data.raw['tips-and-tricks-item-category'][name] = nil end
for _,name in pairs(vanilla_tiptrick_items) do data.raw['tips-and-tricks-item'][name] = nil end

-- tips + tricks take place in the area {{-16,-9},{16,9}}

---@class TipTrickAnimationStep
---@field setup string
---@field update string
---@field proceed string

---@class TipTrickPlayerData
---@field position Position
---@field direction defines.direction
---@field use_cursor boolean

---@class TipTrickSetup_params
---@field zoom number
---@field altmode boolean
---@field player TipTrickPlayerData|nil
---@field use_io boolean
---@field setup string|nil
---@field sequence TipTrickAnimationStep[]|nil
---@field update string|nil

-- center the camera, set zoom, turn Alt mode on/off and unpause the game
---@param params TipTrickSetup_params
function tipTrickSetup(params)
	local zoom = params.zoom or 1
	local altmode = params.altmode
	local player = params.player
	local use_io = params.use_io
	local setup = params.setup or ""
	local steps = params.sequence
	local update = params.update

	local init = [[
		game.camera_position = {0,0}
		game.camera_zoom = ]]..zoom..[[
		game.camera_alt_info = ]]..(altmode and "true" or "false")..[[
		game.tick_paused = false
	]]
	if player then
		local pos = player.position or {0,0}
		init = init..[[
			player = game.create_test_player{name="Niet"}
			player.teleport{]]..(pos.x or pos[1])..","..(pos.y or pos[2])..[[}
			player.character.direction = ]]..(player.direction or defines.direction.north)..[[
			game.camera_player = player

			---@param target LuaEntity|Position
			---@return boolean True if we've arrived
			function runTowards(target)
				local pos1 = player.character.position
				local pos2 = target.position or target
				local dx = pos2.x - pos1.x
				local dy = pos1.y - pos2.y -- swap Y positions because geometry has +Y go up but game has +Y go down
				local distance2 = dx*dx + dy*dy
				if distance2 < 1 then
					player.character.walking_state = {walking=false, direction=player.character.direction}
					return true
				end
				local angle = math.atan2(dy,dx)
				-- convert angle to direction
				local direction = math.floor((1.25 - angle/math.pi/2) * 8 + 0.5) % 8
				player.character.walking_state = {walking=true, direction=direction}
				return false
			end
		]]
		if player.use_cursor then
			init = init..[[
				game.camera_player_cursor_position = player.position
			]]
		end
	end

	if use_io then
		init = init..[[
			-- simplified version of io.addConnection, takes precomputed position and direction rather than an offset and rotation, and a set belt tier
			---@param position Position
			---@param direction defines.direction
			---@param tier uint8 1-5
			---@param entity LuaEntity
			---@param mode '"input"'|'"output"'
			function createLoader(position, direction, tier, entity, mode)
				assert(mode == "input" or mode == "output", "Invalid mode "..mode..", expected 'input' or 'output'")

				local belt, inserter_left, inserter_right
				if tier > 0 then
					belt = entity.surface.create_entity{
						name = "loader-conveyor-belt-mk-"..tier,
						position = position,
						direction = direction,
						force = entity.force,
						raise_built = true
					}

					local target_position = entity.position
					local belt_shift = {
						[defines.direction.north] = {{-0.25,0},{0.25,0}},
						[defines.direction.east] = {{0,-0.25},{0,0.25}},
						[defines.direction.south] = {{0.25,0},{-0.25,0}},
						[defines.direction.west] = {{0,0.25},{0,-0.25}}
					}
					local belt_left_position = {x=belt.position.x + belt_shift[direction][1][1], y=belt.position.y + belt_shift[direction][1][2]}
					local belt_right_position = {x=belt.position.x + belt_shift[direction][2][1], y=belt.position.y + belt_shift[direction][2][2]}

					inserter_left = entity.surface.create_entity{
						name = "loader-inserter",
						position = entity.position,
						direction = direction,
						force = entity.force,
						raise_built = true
					}
					inserter_left.pickup_position = mode == "input" and belt_left_position or target_position
					inserter_left.drop_position = mode == "input" and target_position or belt_left_position
					inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this

					inserter_right = entity.surface.create_entity{
						name = "loader-inserter",
						position = entity.position,
						direction = direction,
						force = entity.force,
						raise_built = true
					}
					inserter_right.pickup_position = mode == "input" and belt_right_position or target_position
					inserter_right.drop_position = mode == "input" and target_position or belt_right_position
					inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
				end

				local sprite = mode == "input" and "indication_line" or "indication_arrow"
				local visual = rendering.draw_sprite{
					sprite = "utility."..sprite,
					orientation = direction/8,
					render_layer = "arrow",
					target = entity,
					target_offset = {
						(position.x or position[1]) - entity.position.x,
						(position.y or position[2]) - entity.position.y
					},
					surface = entity.surface,
					only_in_alt_mode = true
				}

				-- pack it all up nice
				local struct = {
					target = entity,
					belt = belt,
					inserter_left = inserter_left,
					inserter_right = inserter_right,
					visual = visual
				}
				return struct
			end
		]]
	end

	if setup then
		init = init..setup
	end

	if steps then
		for i=1,#steps do
			local step = steps[i]
			init = init..[[
				function step_]]..i..[[()
					]]..step.setup..[[
					script.on_nth_tick(1, function()
						]]..step.update..[[
						if ]]..step.proceed..[[ then
							step_]]..(i+1)..[[()
						end
					end)
				end
			]]
		end
		init = init..[[
			function step_]]..(#steps+1)..[[()
				step_1()
			end
			step_1()
		]]
	elseif update then
		init = init..[[
			script.on_nth_tick(1, function()
				]]..update..[[
			end)
		]]
	end
	return init
end

data:extend{
	require(modpath.."prototypes.tips-and-tricks.introduction"),
	{
		type = "technology",
		name = "tips-and-tricks-melee-combat",
		icon = graphics.."empty.png",
		icon_size = 32,
		hidden = true,
		unit = {
			count = 1,
			time = 1,
			ingredients = {}
		},
		prerequisites = {},
		effects = {}
	},
	require(modpath.."prototypes.tips-and-tricks.melee-combat"),
	{
		type = "technology",
		name = "tips-and-tricks-build-gun",
		icon = graphics.."empty.png",
		icon_size = 32,
		hidden = true,
		unit = {
			count = 1,
			time = 1,
			ingredients = {}
		},
		prerequisites = {},
		effects = {}
	},
	require(modpath.."prototypes.tips-and-tricks.build-gun"),
	{
		type = "technology",
		name = "tips-and-tricks-power-trip",
		icon = graphics.."empty.png",
		icon_size = 32,
		hidden = true,
		unit = {
			count = 1,
			time = 1,
			ingredients = {}
		},
		prerequisites = {},
		effects = {}
	},
	require(modpath.."prototypes.tips-and-tricks.power-trip"),
	require(modpath.."prototypes.tips-and-tricks.conveyor-belts"),
	require(modpath.."prototypes.tips-and-tricks.smart-fast-transfer"),
	require(modpath.."prototypes.tips-and-tricks.train-loading")
}
