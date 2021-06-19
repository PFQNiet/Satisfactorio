-- jump pad launch is initiated by entering the pseudo-vehicle
-- uses global.jump_pads.pads to record the range setting for a given jump pad (max = 40, default = max)
-- uses global.jump_pads.visualisation to track player -> arrow
-- uses global.jump_pads.launch to track player -> movement data
-- uses global.jump_pads.rebounce to track visited jump pads in a chain, to detect a loop and break out of it
-- on landing, player takes "fall damage" unless they land on U-Jelly Landing Pad. If they land on water, they die instantly.

local launcher = "jump-pad"
local vehicle = launcher.."-car"
local flying = launcher.."-flying"
local shadow = launcher.."-flying-shadow"
local landing = "u-jelly-landing-pad"

local script_data = {
	pads = {},
	launch = {},
	rebounce = {},
	visualisation = {}
}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == launcher then
		entity.surface.create_entity{
			name = vehicle,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		script_data.pads[entity.unit_number] = 40
	end
end
local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == launcher then
		local car = entity.surface.find_entity(vehicle, entity.position)
		if car and car.valid then
			car.destroy()
		end
		script_data.pads[entity.unit_number] = nil
	elseif entity.name == vehicle then
		local floor = entity.surface.find_entity(launcher, entity.position)
		if floor and floor.valid then
			script_data.pads[floor.unit_number] = nil
			floor.destroy()
		end
	end
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

local vectors = {
	[defines.direction.north] = {0,-1},
	[defines.direction.east] = {1,0},
	[defines.direction.south] = {0,1},
	[defines.direction.west] = {-1,0}
}
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
local function onTick(event)
	local launch = 	script_data.launch
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
						-- if we landed on jelly then we're good, otherwise take some fall damage (that'll just regen anyway so whatever lol XD)
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

local function onInteract(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.name == launcher then
		local visualisation = script_data.visualisation
		if visualisation[player.index] then
			for _,part in pairs(visualisation[player.index]) do
				rendering.destroy(part)
			end
		end
		local entity = player.selected
		local tris = {}
		local range = script_data.pads[entity.unit_number]
		local vector = vectors[entity.direction]
		local max_z = 80-range
		local prev = {0,0,0.25}
		local o = {vector[2],vector[1]}
		for i=1,58 do
			local position = i/60
			local x = vector[1] * position * range
			local y = vector[2] * position * range
			local z = max_z/4*math.sin(position*math.pi) -- Z axis (representation)
			y = y-z
			-- "width" of the arrow is based on the position along the arc
			local w = math.sin(position*math.pi)/4+0.25
			table.insert(tris,rendering.draw_polygon{
				color = {0.75,0.75,0,0.75},
				vertices = {
					{target={prev[1]+o[1]*prev[3],prev[2]+o[2]*prev[3]}},
					{target={x+o[1]*w,y+o[2]*w}},
					{target={x-o[1]*w,y-o[2]*w}}
				},
				target = entity,
				surface = entity.surface,
				time_to_live = 5*60,
				players = {player}
			})
			table.insert(tris,rendering.draw_polygon{
				color = {0.75,0.75,0,0.75},
				vertices = {
					{target={prev[1]+o[1]*prev[3],prev[2]+o[2]*prev[3]}},
					{target={x-o[1]*w,y-o[2]*w}},
					{target={prev[1]-o[1]*prev[3],prev[2]-o[2]*prev[3]}}
				},
				target = entity,
				surface = entity.surface,
				time_to_live = 5*60,
				players = {player}
			})
			prev = {x,y,w}
		end
		-- arrow head
		local position = 58/60
		local x = vector[1] * position * range
		local y = vector[2] * position * range
		local z = max_z/4*math.sin(position*math.pi) -- Z axis (representation)
		y = y-z
		local w = 1.5
		table.insert(tris,rendering.draw_polygon{
			color = {0.75,0.75,0,0.75},
			vertices = {
				{target={x+o[1]*w,y+o[2]*w}},
				{target={vector[1]*range,vector[2]*range}},
				{target={x-o[1]*w,y-o[2]*w}}
			},
			target = entity,
			surface = entity.surface,
			time_to_live = 5*60,
			players = {player}
		})
		table.insert(tris,rendering.draw_sprite{
			sprite = "jump-pad-landing",
			target = entity,
			target_offset = {vector[1]*range,vector[2]*range},
			surface = entity.surface,
			time_to_live = 5*60,
			players = {player}
		})
		
		visualisation[player.index] = tris
	end
end
local function onRangeDown(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.name == launcher then
		local entity = player.selected
		script_data.pads[entity.unit_number] = math.max(4,script_data.pads[entity.unit_number]-1)
		onInteract(event)
	end
end
local function onRangeUp(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.name == launcher then
		local entity = player.selected
		script_data.pads[entity.unit_number] = math.min(40,script_data.pads[entity.unit_number]+1)
		onInteract(event)
	end
end

return {
	on_init = function()
		global.launch_pads = global.launch_pads or script_data
	end,
	on_load = function()
		script_data = global.launch_pads or script_data
	end,
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_player_rotated_entity] = function(event)
			onRotated(event)
			onInteract(event)
		end,

		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_tick] = onTick,

		["interact"] = onInteract,
		["tile-smaller"] = onRangeDown,
		["tile-bigger"] = onRangeUp,
		[defines.events.on_gui_opened] = function(event)
			if event.entity and event.entity.valid and event.entity.name == launcher then
				game.players[event.player_index].opened = nil
			end
		end
	}
}
