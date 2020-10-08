-- jump pad launch is initiated by entering the pseudo-vehicle
-- uses global['jump-pad-launch'] to track player -> movement data
-- on landing, player takes "fall damage" unless they land on U-Jelly Landing Pad. If they land on water, they die instantly.

local launcher = "jump-pad"
local vehicle = launcher.."-car"
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
	if entity and entity.valid and entity.name == vehicle then
		if player.driving then
			local enter = entity.surface.find_entity(launcher,entity.position)
			player.driving = false
			if enter.energy == 0 then
				-- must have power
				player.character.teleport(entity.position)
			else
				-- initiate YEETage
				local character = player.character
				if not global['jump-pad-launch'] then global['jump-pad-launch'] = {} end
				global['jump-pad-launch'][player.index] = {
					character = character,
					start = enter.position,
					time = 0,
					direction = enter.direction
				}
				character.surface.play_sound{
					path = "jump-pad-launch",
					position = enter.position
				}
				character.destructible = false -- invincible while flying
			end
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
		y = y - 10*math.sin(position*math.pi) -- Z axis (representation)
		local character = data.character
		character.teleport({x,y})
		character.direction = data.direction -- force character to face forward despite keyboard input

		if data.time == 120 then
			-- landing! check for collision and bump accordingly - should wind up close by at worst
			character.destructible = true
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
				character.teleport({character.position.x-5, character.position.y})
				-- then find an empty space at the target
				character.teleport(surface.find_non_colliding_position("character",{x,y},0,0.05))
				-- if we landed on jelly then we're good, otherwise take some fall damage (that'll just regen anyway so whatever lol XD)
				local jelly = surface.find_entity(landing, character.position)
				if not jelly or jelly.energy == 0 then
					character.damage(40, game.forces.neutral) -- so you can unsafe-jump twice but the third time is death
				end
			end
			global['jump-pad-launch'][pid] = nil
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
