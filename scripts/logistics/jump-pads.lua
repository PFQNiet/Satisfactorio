-- jump pad launch is initiated by entering the pseudo-vehicle
-- uses global.jump_pads.pads to record the range setting for a given jump pad (max = 40, default = max)
-- uses global.jump_pads.visualisation to track player -> arrow
-- uses global.jump_pads.launch to track player -> movement data
-- uses global.jump_pads.rebounce to track visited jump pads in a chain, to detect a loop and break out of it
-- on landing, player takes "fall damage" unless they land on U-Jelly Landing Pad. If they land on water, they die instantly.

local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local launcher = "jump-pad"
local vehicle = launcher.."-car"
local flying = launcher.."-flying"
local shadow = launcher.."-flying-shadow"
local landing = "u-jelly-landing-pad"

---@class JumpPadData
---@field player LuaPlayer
---@field start Position
---@field time uint Number of ticks since launch
---@field direction defines.direction
---@field range number Range setting of the pad at the time of launch
---@field car LuaEntity
---@field shadow uint64

---@class global.jump_pads
---@field pads table<uint, number> Map unit number of jump pad to its range setting
---@field launch table<uint, JumpPadData> Map player ID to jumping data
---@field rebounce table<uint, table<uint, boolean>> Map player ID to a dictionary of visited jump pad IDs in the current chain
---@field visualisation table<uint, uint64[]> Map player ID to visualisation components
local script_data = {
	pads = {},
	launch = {},
	rebounce = {},
	visualisation = {}
}

---@param entity LuaEntity
local function onBuilt(entity)
	local car = entity.surface.create_entity{
		name = vehicle,
		position = entity.position,
		direction = entity.direction,
		force = entity.force,
		raise_built = true
	}
	link.register(entity, car)
	script_data.pads[entity.unit_number] = 40
end
---@param entity LuaEntity
local function onRemoved(entity)
	local car = entity.surface.find_entity(vehicle, entity.position)
	if car and car.valid then
		car.destroy()
	end
	script_data.pads[entity.unit_number] = nil
end
local function onRotated(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == launcher then
		local car = entity.surface.find_entity(vehicle, entity.position)
		if car and car.valid then
			car.direction = entity.direction
		end
	end
end

---@type table<defines.direction, Vector>
local vectors = {
	[defines.direction.north] = {0,-1},
	[defines.direction.east] = {1,0},
	[defines.direction.south] = {0,1},
	[defines.direction.west] = {-1,0}
}
---@param event on_player_driving_changed_state
local function onVehicle(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if player.driving then
		if entity and entity.valid and entity.name == vehicle then
			local enter = entity.surface.find_entity(launcher,entity.position)
			player.driving = false
			if enter.energy == 0 then
				-- must have power
				if player.character then
					player.character.teleport(entity.position)
				end
			else
				-- initiate YEETage
				local rebounce = script_data.rebounce
				if not rebounce[player.index] then rebounce[player.index] = {} end
				rebounce[player.index][enter.unit_number] = true

				local car2 = enter.surface.create_entity{
					name = flying,
					force = enter.force,
					position = enter.position,
					direction = enter.direction
				}
				car2.set_driver(player)
				local graphic = rendering.draw_sprite{
					sprite = shadow.."-"..enter.direction,
					surface = enter.surface,
					target = car2
				}
				player.surface.play_sound{
					path = "jump-pad-launch",
					position = enter.position
				}
				script_data.launch[player.index] = {
					player = player,
					start = enter.position,
					time = 0,
					direction = enter.direction,
					range = script_data.pads[enter.unit_number],
					car = car2,
					shadow = graphic
				}
			end
		end
	else
		-- check if player is being yeeted and put them back in if so
		local yeet = script_data.launch[player.index]
		if yeet then
			yeet.car.set_driver(player)
		end
	end
end
local function onTick()
	local launch = script_data.launch
	for pid,data in pairs(launch) do
		data.time = data.time + 1
		local position = data.time / 120
		local x = data.start.x + vectors[data.direction][1] * position * data.range
		local y = data.start.y + vectors[data.direction][2] * position * data.range
		local z = (80-data.range)/4*math.sin(position*math.pi) -- Z axis (representation)
		y = y - z
		local car = data.car
		car.teleport({x,y})
		rendering.set_target(data.shadow, car, {z+1,z})
		rendering.set_x_scale(data.shadow, 1-z/40)
		rendering.set_y_scale(data.shadow, 1-z/40)

		if data.time == 120 then
			-- landing! check for collision and bump accordingly - should wind up close by at worst
			local character = data.player.character
			launch[pid] = nil
			car.destroy()
			if character then
				-- if we landed on water, just die XD
				local surface = character.surface
				local water_tile = surface.find_tiles_filtered{
					position = {x,y},
					radius = 1,
					limit = 1,
					collision_mask = "player-layer" -- tiles that collide with the player are impassible - in vanilla that's just water but let's support mods too!
				}
				if #water_tile > 0 then
					character.teleport({x, y})
					character.die()
				else
					-- move the character aside so it is out of the way of its own collision check
					character.teleport({x-5, y})
					-- then find an empty space at the target
					character.teleport(surface.find_non_colliding_position("character",{x,y},0,0.05))
					-- if we landed on another jump pad, re-bounce
					local rebounce = surface.find_entity(launcher, character.position)
					local pad_rebounce = script_data.rebounce
					if rebounce and rebounce.energy > 0 and not pad_rebounce[data.player.index][rebounce.unit_number] then
						local car = surface.find_entity(vehicle, rebounce.position)
						if car then
							pad_rebounce[data.player.index][rebounce.unit_number] = true
							car.set_driver(data.player)
						end
					else
						pad_rebounce[data.player.index] = nil
						-- if we landed on jelly then we're good, otherwise take some fall damage
						local jelly = surface.find_entity(landing, character.position)
						if not jelly or jelly.energy == 0 then
							-- last thing to check is a parachute - using one will nullify fall damage
							local inventory = data.player.get_inventory(defines.inventory.character_armor)
							local armour = inventory[1]
							if armour.valid_for_read and armour.name == "parachute" then
								inventory.remove{name="parachute",count=1}
							else
								character.damage(29, game.forces.neutral) -- so you can unsafe-jump a few times but death is possible
							end
						end
					end
				end
			end
		end
	end
end

---@param player LuaPlayer
local function drawVisualisationArrow(player)
	if player.selected and player.selected.name == launcher then
		local visualisation = script_data.visualisation
		if visualisation[player.index] then
			for _,part in pairs(visualisation[player.index]) do
				rendering.destroy(part)
			end
		end
		local entity = player.selected
		local range = script_data.pads[entity.unit_number]
		local vector = vectors[entity.direction]
		local max_z = 80-range
		local o = {vector[2],vector[1]}
		local vertices = {}
		for i=0,59 do
			local position = math.min(58,i)/60 -- final loop uses a degenerate triangle to widen in preparation for the arrowhead
			local x = vector[1] * position * range
			local y = vector[2] * position * range
			local z = max_z/4*math.sin(position*math.pi) -- Z axis (representation)
			y = y-z
			-- "width" of the arrow is based on the position along the arc
			local w = math.sin(position*math.pi)/4+0.25
			if i == 59 then w = 1.5 end -- prepare for arrowhead
			table.insert(vertices, {target={x+o[1]*w, y+o[2]*w}})
			table.insert(vertices, {target={x-o[1]*w, y-o[2]*w}})
		end
		table.insert(vertices, {target={vector[1]*range, vector[2]*range}})
		local vis = {
			rendering.draw_polygon{
				color = {0.75,0.75,0,0.75},
				vertices = vertices,
				target = entity,
				surface = entity.surface,
				time_to_live = 5*60,
				players = {player}
			},
			rendering.draw_sprite{
				sprite = "jump-pad-landing",
				target = entity,
				target_offset = {vector[1]*range,vector[2]*range},
				surface = entity.surface,
				time_to_live = 5*60,
				players = {player}
			}
		}

		visualisation[player.index] = vis
	end
end
local function onRangeDown(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.name == launcher then
		local entity = player.selected
		script_data.pads[entity.unit_number] = math.max(4,script_data.pads[entity.unit_number]-1)
		drawVisualisationArrow(player)
	end
end
local function onRangeUp(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.name == launcher then
		local entity = player.selected
		script_data.pads[entity.unit_number] = math.min(40,script_data.pads[entity.unit_number]+1)
		drawVisualisationArrow(player)
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.launch_pads = global.launch_pads or script_data
	end,
	on_load = function()
		script_data = global.launch_pads or script_data
	end,
	on_build = {
		callback = onBuilt,
		filter = {name=launcher}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name=launcher}
	},
	events = {
		[defines.events.on_player_rotated_entity] = function(event)
			onRotated(event)
			drawVisualisationArrow(game.players[event.player_index])
		end,

		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_tick] = onTick,

		["interact"] = function(event) drawVisualisationArrow(game.players[event.player_index]) end,
		["tile-smaller"] = onRangeDown,
		["tile-bigger"] = onRangeUp,
		[defines.events.on_gui_opened] = function(event)
			if event.entity and event.entity.valid and event.entity.name == launcher then
				game.players[event.player_index].opened = nil
			end
		end
	}
}
