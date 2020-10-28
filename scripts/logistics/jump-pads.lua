-- jump pad launch is initiated by entering the pseudo-vehicle
-- uses global['jump-pad-launch'] to track player -> movement data
-- on landing, player takes "fall damage" unless they land on U-Jelly Landing Pad. If they land on water, they die instantly.

local launcher = "jump-pad"
local vehicle = launcher.."-car"
local flying = launcher.."-flying"
local shadow = launcher.."-flying-shadow"
local landing = "u-jelly-landing-pad"

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
	elseif entity.name == car then
		local floor = entity.surface.find_entity(launcher, entity.position)
		if floor and floor.valid then
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
	elseif entity.name == car then -- can you even rotate cars? can you even select the car since it's underneath the floor? idk lol
		local floor = entity.surface.find_entity(launcher, entity.position)
		if floor and floor.valid then
			floor.direction = car.direction
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
				if not global['jump-pad-launch'] then global['jump-pad-launch'] = {} end
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
				global['jump-pad-launch'][player.index] = {
					player = player,
					start = enter.position,
					time = 0,
					direction = enter.direction,
					car = car2,
					shadow = graphic
				}
				player.surface.play_sound{
					path = "jump-pad-launch",
					position = enter.position
				}
			end
		end
	else
		-- check if player is being yeeted and put them back in if so
		local yeet = global['jump-pad-launch'] and global['jump-pad-launch'][player.index]
		if yeet then
			yeet.car.set_driver(player)
		end
	end
end
local function onTick(event)
	if not global['jump-pad-launch'] then return end
	for pid,data in pairs(global['jump-pad-launch']) do
		local player = game.players[pid]
		data.time = data.time + 1
		local position = data.time / 120
		local x = data.start.x + vectors[data.direction][1] * position * 40
		local y = data.start.y + vectors[data.direction][2] * position * 40
		local z = 10*math.sin(position*math.pi) -- Z axis (representation)
		y = y - z
		local car = data.car
		car.teleport({x,y})
		rendering.set_target(data.shadow, car, {z+1,z})
		rendering.set_x_scale(data.shadow, 1-z/20)
		rendering.set_y_scale(data.shadow, 1-z/20)

		if data.time == 120 then
			-- landing! check for collision and bump accordingly - should wind up close by at worst
			local character = data.player.character
			global['jump-pad-launch'][pid] = nil
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
					character.die()
				else
					-- move the character aside so it is out of the way of its own collision check
					character.teleport({x-5, y})
					-- then find an empty space at the target
					character.teleport(surface.find_non_colliding_position("character",{x,y},0,0.05))
					-- if we landed on another jump pad, re-bounce
					local rebounce = surface.find_entity(launcher, character.position)
					if rebounce and rebounce.energy > 0 then
						local car = surface.find_entity(vehicle, rebounce.position)
						if car then
							car.set_driver(data.player)
						end
					else
						-- if we landed on jelly then we're good, otherwise take some fall damage (that'll just regen anyway so whatever lol XD)
						local jelly = surface.find_entity(landing, character.position)
						if not jelly or jelly.energy == 0 then
							character.damage(40, game.forces.neutral) -- so you can unsafe-jump twice but the third time is death
						end
					end
				end
			end
		end
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_player_rotated_entity] = onRotated,

		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_tick] = onTick
	}
}
