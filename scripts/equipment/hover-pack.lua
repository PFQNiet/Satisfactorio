-- with hover pack equipped, player can press J to jump and fly indefinitely in any direction, draining 100MW from nearby power poles
-- riding_state can be used to get player's directional inputs to apply thrust
-- uses global.hoverpack_flight to track player > {fake car, shadow, height, momentum}
local item = "hover-pack"
local vehicle = item.."-flying"
local shadow = item.."-flying-shadow"
local interface = item.."-eei"

local script_data = {}
local sqrt2 = math.sqrt(2)
local math2d = require("math2d")

local function findNearestPowerPole(surface,pos)
	for r=1,16,1 do
		local pole = surface.find_entities_filtered{
			type = "electric-pole",
			position = pos,
			radius = r,
			limit = 1
		}[1]
		if pole then return pole end
	end
	return nil
end

local function onJump(event)
	local player = game.players[event.player_index]
	local inventory = player.get_inventory(defines.inventory.character_armor)
	if not inventory then return end
	local armour = inventory[1]
	if armour.valid_for_read and armour.name == item and not player.driving then
		-- start flying immediately, if takeoff fails due to lack of power then player is alerted
		-- spawn a car and get into it
		local car = player.surface.create_entity{
			name = vehicle,
			position = player.position,
			force = player.force,
			direction = player.character and player.character.direction or defines.direction.north,
			raise_built = true
		}
		car.set_driver(player)
		car.operable = false
		local struct = {
			player = player,
			car = car,
			interface = car.surface.create_entity{
				name = interface,
				position = car.position,
				force = car.force,
				raise_built = true
			},
			line = rendering.draw_line{
				color = {0,212,255,192},
				width = 3,
				dash_length = 0.2,
				gap_length = 0.05,
				from = car,
				from_offset = {0,-0.8},
				to = car.position,
				surface = car.surface,
				visible = false,
				players = {player}
			},
			aura = rendering.draw_circle{
				color = {0,212,255,192},
				radius = 16,
				width = 3,
				filled = false,
				target = car,
				surface = car.surface,
				players = {player}
			},
			shadow = rendering.draw_sprite{
				sprite = shadow.."-"..car.direction,
				surface = car.surface,
				target = car
			},
			height = 0,
			start_tick = event.tick,
			exiting = false,
			position = {car.position.x,car.position.y},
			momentum = {0,0}
		}
		script_data[player.index] = struct
	end
end

local function onVehicle(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity and entity.valid and entity.name == vehicle then
		local data = script_data[player.index]
		if not player.driving and data then
			-- put the player back in the car, and request descent
			data.car.set_driver(player)
			data.exiting = true
		end
	end
end

local function onTick(event)
	for pid,struct in pairs(script_data) do
		local powersource = findNearestPowerPole(struct.car.surface,struct.position)
		if struct.exiting or (struct.start_tick < event.tick-2 and struct.interface.energy == 0) then powersource = nil end
		-- local powerdistance = powersource and math2d.position.distance(struct.position, powersource.position) or math.huge
		if powersource then
			rendering.set_visible(struct.line, true)
			rendering.set_to(struct.line, math2d.position.add(powersource.position,{0,-2.5}))
		else
			rendering.set_visible(struct.line, false)
		end

		local altitude = 5
		if struct.height < altitude and powersource then
			struct.height = struct.height + (altitude-struct.height)*0.05
		end
		if struct.height > 0 and not powersource then
			struct.height = math.max(0, struct.height - 0.1)
		end

		local driving = struct.player.riding_state
		local acceleration = {0,0}

		if driving.direction == defines.riding.direction.left then acceleration[1] = -1 end
		if driving.direction == defines.riding.direction.right then acceleration[1] = 1 end
		if driving.acceleration == defines.riding.acceleration.accelerating then acceleration[2] = -1 end
		if driving.acceleration == defines.riding.acceleration.reversing then acceleration[2] = 1 end
		-- since the car isn't moving on its own power, S will always be "reversing". "braking" isn't used.
		if acceleration[1] ~= 0 and acceleration[2] ~= 0 then
			-- diagonal movement, scale down by sqrt(2)
			acceleration[1] = acceleration[1]/sqrt2
			acceleration[2] = acceleration[2]/sqrt2
		end

		struct.momentum[1] = struct.momentum[1] * 0.85 + acceleration[1] * 0.06
		struct.momentum[2] = struct.momentum[2] * 0.85 + acceleration[2] * 0.06
		struct.position = {
			struct.position[1] + struct.momentum[1],
			struct.position[2] + struct.momentum[2]
		}
		struct.car.teleport{
			struct.position[1],
			struct.position[2] - struct.height
		}
		struct.interface.teleport{
			struct.position[1],
			struct.position[2]
		}
		rendering.set_target(struct.aura, struct.car, {0,struct.height}) -- stay at ground level
		rendering.set_target(struct.shadow, struct.car, {struct.height+1,struct.height})
		rendering.set_x_scale(struct.shadow, 1-struct.height/40)
		rendering.set_y_scale(struct.shadow, 1-struct.height/40)
		if acceleration[1] ~= 0 or acceleration[2] ~= 0 then
			local angle = math.atan2(-acceleration[2], acceleration[1])
			struct.car.orientation = math.fmod(2 + 0.25 - angle/(math.pi*2), 1)
			local direction = math.floor(struct.car.orientation*8+0.5)%8
			rendering.set_sprite(struct.shadow, shadow.."-"..direction)
		end

		if not powersource and struct.height <= 0 then
			script_data[struct.player.index] = nil
			rendering.destroy(struct.line) -- manual cleanup required
			local direction = math.floor(struct.car.orientation*8+0.5)%8
			struct.car.destroy()
			struct.interface.destroy()
			struct.player.teleport(struct.position)
			local character = struct.player.character
			if character then
				-- if we landed on water, just die XD
				local surface = character.surface
				local water_tile = surface.find_tiles_filtered{
					position = struct.position,
					radius = 1,
					limit = 1,
					collision_mask = "player-layer" -- tiles that collide with the player are impassible - in vanilla that's just water but let's support mods too!
				}
				if #water_tile > 0 then
					character.die()
				else
					-- move the character aside so it is out of the way of its own collision check
					character.teleport({struct.position[1]-5, struct.position[2]})
					-- then find an empty space at the target
					character.teleport(surface.find_non_colliding_position("character",struct.position,0,0.05))
					character.direction = direction
				end
			end
			-- if "flight" didn't get off the ground, trigger message
			if event.tick < struct.start_tick + 5 then
				struct.player.surface.create_entity{
					name = "flying-text",
					position = struct.player.position,
					text = {"message.hoverpack-no-power"},
					render_player_index = struct.player.index
				}
				struct.player.play_sound{
					path = "utility/cannot_build"
				}
			end
		end
	end
end

return {
	on_init = function()
		global.hoverpack_flight = global.hoverpack_flight or script_data
	end,
	on_load = function()
		script_data = global.hoverpack_flight or script_data
	end,
	events = {
		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_tick] = onTick,
		["jump"] = onJump
	}
}
