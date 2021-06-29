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

-- center the camera, set zoom, turn Alt mode on/off and unpause the game
---@param params TipTrickSetup_params
function tipTrickSetup(params)
	local zoom = params.zoom or 1
	local altmode = params.altmode
	local player = params.player
	local use_io = params.use_io
	local setup = params.setup or ""
	local steps = params.sequence

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
			---@param mode "input"|"output"
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
	end
	return init
end

-- At least we can have a nice little build to show!
data:extend{
	require(modpath.."prototypes.tips-and-tricks.introduction"),
	require(modpath.."prototypes.tips-and-tricks.melee-combat"),
	require(modpath.."prototypes.tips-and-tricks.build-gun"),
	require(modpath.."prototypes.tips-and-tricks.power-trip"),
	require(modpath.."prototypes.tips-and-tricks.smart-fast-transfer")
}

--[==[ This is all old stuff that needs to be revamped/rewritten/put out of its misery
tiptrickutils = [[
	-- require("math2d")
	math2d = {position={
		ensure_xy = function(pos)
			local new_pos
			if pos.x ~= nil then
				new_pos = {x = pos.x, y = pos.y}
			else
				new_pos = {x = pos[1], y = pos[2]}
			end
			return new_pos
		end,
		rotate_vector = function(vector, angle_in_deg)
			local cosAngle = math.cos(math.rad(angle_in_deg))
			local sinAngle = math.sin(math.rad(angle_in_deg))
			vector = math2d.position.ensure_xy(vector)
			local x = cosAngle * vector.x - sinAngle * vector.y
			local y = sinAngle * vector.x + cosAngle * vector.y
			return {x = x, y = y}
		end,
		add = function(p1, p2)
			p1 = math2d.position.ensure_xy(p1)
			p2 = math2d.position.ensure_xy(p2)
			return {x = p1.x + p2.x, y = p1.y + p2.y}
		end
	}}

	-- input-output doesn't need any particular tracking here
	io = {
		addInput = function(entity, offset, target, direction)
			offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
			local position = math2d.position.add(entity.position, offset)
			direction = direction or defines.direction.north
			local exists = entity.surface.find_entity("loader-conveyor", position)
			if exists then return end

			local belt = entity.surface.create_entity{
				name = "loader-conveyor",
				position = position,
				direction = (entity.direction + direction) % 8,
				force = entity.force
			}
			local inserter_left = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction + direction) % 8,
				force = entity.force
			}
			inserter_left.pickup_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,0.25},((entity.direction+direction)%8)/8*360))
			inserter_left.drop_position = (target or entity).position
			inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local inserter_right = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction + direction) % 8,
				force = entity.force
			}
			inserter_right.pickup_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,0.25},((entity.direction+direction)%8)/8*360))
			inserter_right.drop_position = (target or entity).position
			inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local visual = rendering.draw_sprite{
				sprite = "utility.indication_line",
				orientation = ((entity.direction + direction) % 8)/8,
				render_layer = "arrow",
				target = entity,
				target_offset = {offset.x, offset.y},
				surface = entity.surface,
				only_in_alt_mode = true
			}
			return belt, inserter_left, inserter_right, visual
		end,
		addOutput = function(entity, offset, target, direction)
			offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
			local position = math2d.position.add(entity.position, offset)
			direction = direction or defines.direction.north
			local exists = entity.surface.find_entity("loader-conveyor", position)
			if exists then return end

			local belt = entity.surface.create_entity{
				name = "loader-conveyor",
				position = position,
				direction = (entity.direction+direction)%8,
				force = entity.force
			}
			local inserter_left = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction+direction)%8,
				force = entity.force
			}
			inserter_left.pickup_position = (target or entity).position
			inserter_left.drop_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,-0.49},((entity.direction+direction)%8)/8*360))
			inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local inserter_right = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction+direction)%8,
				force = entity.force
			}
			inserter_right.pickup_position = (target or entity).position
			inserter_right.drop_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,-0.49},((entity.direction+direction)%8)/8*360))
			inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local visual = rendering.draw_sprite{
				sprite = "utility.indication_arrow",
				orientation = ((entity.direction+direction)%8)/8,
				render_layer = "arrow",
				target = entity,
				target_offset = {offset.x, offset.y},
				surface = entity.surface,
				only_in_alt_mode = true
			}
			return belt, inserter_left, inserter_right, visual
		end,
		entities = {
			['smelter'] = {
				inputs = {{0,2}},
				outputs = {{0,-2}}
			},
			['constructor'] = {
				inputs = {{0,2}},
				outputs = {{0,-2}}
			},
			['assembler'] = {
				inputs = {{-1,3},{1,3}},
				outputs = {{0,-3}}
			},
			['miner-mk-1'] = {
				inputs = {},
				outputs = {{0,-6}}
			},
			['storage-container-placeholder'] = {
				inputs = {{0,2}},
				outputs = {{0,-2}}
			},
			['coal-generator-boiler'] = {
				inputs = {{1,1.5}},
				outputs = {}
			},
			['conveyor-splitter'] = {
				inputs = {{0,1}},
				outputs = {{0,-1},{-1,0,defines.direction.west},{1,0,defines.direction.west}}
			}
		},
		generate = function(surface)
			for key,data in pairs(io.entities) do
				local entities = surface.find_entities_filtered{name=key}
				for _,entity in pairs(entities) do
					for _,vector in pairs(data.inputs) do
						io.addInput(entity,{vector[1],vector[2]},entity,vector[3] or defines.direction.north)
					end
					for _,vector in pairs(data.outputs) do
						io.addOutput(entity,{vector[1],vector[2]},entity,vector[3] or defines.direction.north)
					end
				end
			end
		end
	}

]]

require("prototypes.tips-and-tricks.introduction")
require("prototypes.tips-and-tricks.show-info")
require("prototypes.tips-and-tricks.pipette")
data.raw['tips-and-tricks-item']['stack-transfers'].tutorial = nil
require("prototypes.tips-and-tricks.entity-transfers")
require("prototypes.tips-and-tricks.z-dropping")
require("prototypes.tips-and-tricks.shoot-targeting")
-- delete "Inserters" category
data.raw['tips-and-tricks-item-category']['inserters'] = nil
data.raw['tips-and-tricks-item']['inserters'] = nil
data.raw['tips-and-tricks-item']['burner-inserter-refueling'] = nil
data.raw['tips-and-tricks-item']['long-handed-inserters'] = nil
data.raw['tips-and-tricks-item']['move-between-labs'] = nil
data.raw['tips-and-tricks-item']['insertion-limits'] = nil
data.raw['tips-and-tricks-item']['limit-chests'] = nil
-- "Transport belt" tips don't really apply here
data.raw['tips-and-tricks-item-category']['belts'] = nil
data.raw['tips-and-tricks-item']['transport-belts'] = nil
data.raw['tips-and-tricks-item']['belt-lanes'] = nil
data.raw['tips-and-tricks-item']['splitters'] = nil
data.raw['tips-and-tricks-item']['splitter-filters'] = nil
data.raw['tips-and-tricks-item']['underground-belts'] = nil
-- "steam power" isn't used
data.raw['tips-and-tricks-item']['electric-network'] = nil
data.raw['tips-and-tricks-item']['electric-pole-connections'] = nil
data.raw['tips-and-tricks-item']['steam-power'] = nil
data.raw['tips-and-tricks-item']['connect-switch'] = nil
data.raw['tips-and-tricks-item']['low-power'].dependencies = nil
data.raw['tips-and-tricks-item']['low-power'].simulation = nil
data.raw['tips-and-tricks-item']['low-power'].image = "__Satisfactorio__/graphics/tips-and-tricks/power-trip.png"
require("prototypes.tips-and-tricks.copy-entity-settings")
data.raw['tips-and-tricks-item']['copy-paste-filters'] = nil -- Possibly repurpose this with Smart Splitters?
data.raw['tips-and-tricks-item']['copy-paste-requester-chest'] = nil
data.raw['tips-and-tricks-item']['copy-paste-spidertron'] = nil
require("prototypes.tips-and-tricks.drag-building")
data.raw['tips-and-tricks-item']['fast-obstacle-traversing'] = nil
-- remove "train" section, I can't be bothered making it work with electric trains XD
data.raw['tips-and-tricks-item-category']['trains'] = nil
data.raw['tips-and-tricks-item']['trains'] = nil
data.raw['tips-and-tricks-item']['rail-building'] = nil
data.raw['tips-and-tricks-item']['train-stops'] = nil
data.raw['tips-and-tricks-item']['rail-signals-basic'] = nil
data.raw['tips-and-tricks-item']['rail-signals-advanced'] = nil
data.raw['tips-and-tricks-item']['gate-over-rail'] = nil
data.raw['tips-and-tricks-item']['pump-connection'] = nil
data.raw['tips-and-tricks-item']['train-stop-same-name'] = nil
data.raw['tips-and-tricks-item']['ghost-rail-planner'] = nil
-- Drop the robot-related stuff
data.raw['tips-and-tricks-item-category']['logistic-network'] = nil
data.raw['tips-and-tricks-item']['logistic-network'] = nil
data.raw['tips-and-tricks-item']['personal-logistics'] = nil
data.raw['tips-and-tricks-item']['construction-robots'] = nil
data.raw['tips-and-tricks-item']['passive-provider-chest'] = nil
data.raw['tips-and-tricks-item']['storage-chest'] = nil
data.raw['tips-and-tricks-item']['requester-chest'] = nil
data.raw['tips-and-tricks-item']['active-provider-chest'] = nil
data.raw['tips-and-tricks-item']['buffer-chest'] = nil
-- No fast-replace (it only affects Miners and Belts anyway...)
data.raw['tips-and-tricks-item-category']['fast-replace'] = nil
data.raw['tips-and-tricks-item']['fast-replace'] = nil
data.raw['tips-and-tricks-item']['fast-replace-direction'] = nil
data.raw['tips-and-tricks-item']['fast-replace-belt-splitter'] = nil
data.raw['tips-and-tricks-item']['fast-replace-belt-underground'] = nil
require("prototypes.tips-and-tricks.ghost-building")
data.raw['tips-and-tricks-item']['rotating-assemblers'] = nil
data.raw['tips-and-tricks-item']['circuit-network'] = nil


--[=[
- introduction (5 minutes)
- game-interaction
-- show-info (dependency: introduction)
-- e-confirm (5 times not using E)
-- clear-cursor
-- pipette (built 120 entities without using Q)
-- stack-transfers (manually transfer 20 times without using stack transfer)
-- entity-transfters (30 minutes after stack-transfers)
-- z-dropping (30 minutes after entity-transfers)
-- shoot-targeting (135 minutes into the game)
-- bulk-crafting (hand-craft single items)
- inserters
-- inserters (unlocked inserter)
-- burner-inserter-refueling (build 3 burner inserters)
-- long-handed-inserters (research automation)
-- move-between-labs (build 3 labs)
-- insertion-limits (build 5 inserters)
-- limit-chests (build containers and inserters)
- belts
-- transport-belts (unlock transport belt)
-- belt-lanes (build 30 belts)
-- splitters (research logistics)
-- splitter-filters (build 10 splitters)
-- underground-belts (research logistics)
- electric-network
-- electric-network (unlock steam engine and boiler + 15 minutes, or build steam engine, boiler or offshore pump)
-- steam-power (dependency: electric-network)
-- low-power (low power 3x)
-- electric-pole-connections (4 hours elapsed, then build 15 more electric poles)
-- connect-switch (build power-switch)
- copy-paste
-- copy-entity-settings (set recipe in 3 consecutive buildings without pasting)
-- copy-paste-trains (build 3 locomotives)
-- copy-paste-filters (build 3 filter inserters)
-- copy-paste-requester-chest (build 10 requesters and set 20 requests)
-- copy-paste-spidertron (build 2 spidertrons)
- drag-building
-- drag-building (build 60 entities without dragging 10)
-- drag-building-poles (build 15 power poles without dragging 3)
-- drag-building-underground-belts (build 30 underground belts wihtout dragging 3)
-- fast-belt-bending (drag 200 belts without bending)
-- fast-obstacle-traversing (drag 200 belts and 20 undergrounds without traversing)
- trains
-- trains (research railway)
-- rail-building (build 1 rail)
-- train-stops (build 1 train stop or research automated rail transportation and build 30 rails)
-- rail-signals-basic (build 1 rail signal or research rail signals and buid 2 trains)
-- rail-signals-advanced (build 30 rail signals or 1 chain signal)
-- gate-over-rail (build 60 rails, 50 walls and research gates)
-- pump-connection (build fluid wagon)
-- train-stop-same-name (build 4 train stops)
- logistic-network
-- logistic-network (research construction or logistic bots)
-- personal-logistics (research logistic bots)
-- construction-robots (research construction bots)
-- passive-provider-chest (dependency: logistic-network)
-- storage-chest (dependency: logistic-network)
-- requester-chest (dependency: logistic-network)
-- active-provider-chest (dependency: logistic-network)
-- buffer-chest (dependency: logistic-network)
- ghost-building
-- ghost-building (research construction bots)
-- ghost-rail-planner (build roboport or personal roboport, build 100 rails)
-- copy-paste (2 hours after unlocking ghost-building)
- fast-replace
-- fast-replace (build 10 steel furnaces, AM2 or AM3)
-- fast-replace-direction (build 50 belts)
-- fast-replace-belt-splitter (build 20 splitters without fast-replacing)
-- fast-replace-belt-underground (build 20 underground belts)
- rotating-assemblers (set recipe using fluid)
- circuit-network (research circuit network + 30 minutes)
]=]
]==]
