-- with jetpack equipped, player can press J to jump and fly for 6 seconds in any direction, consuming 2 Packaged Fuel from the inventory
-- riding_state can be used to get player's directional inputs to apply thrust
-- uses global.jetpack_flight to track player > {fake car, shadow, flight time, momentum}
local item = "jetpack"
local vehicle = item.."-flying"
local shadow = item.."-flying-shadow"
local fuel = "packaged-fuel"

---@class JetpackData
---@field player LuaPlayer
---@field car LuaEntity Car
---@field shadow uint64
---@field ring uint64
---@field arc uint64
---@field time uint
---@field position Position
---@field momentum Vector

---@alias global.jetpack_flight table<uint, JetpackData>
---@type global.jetpack_flight
local script_data = {}

local sqrt2 = math.sqrt(2)

local function onJump(event)
	local player = game.players[event.player_index]
	local armourslot = player.get_inventory(defines.inventory.character_armor)
	if not armourslot then return end
	local armour = armourslot[1]
	if armour.valid_for_read and armour.name == item and not player.driving then
		-- check for fuel
		local inventory = player.get_main_inventory()
		if inventory.get_item_count(fuel) < 2 then
			player.surface.create_entity{
				name = "flying-text",
				position = player.position,
				text = {"message.jetpack-no-fuel"},
				render_player_index = player.index
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
		else
			inventory.remove{name=fuel,count=2}
			local remain = inventory.get_item_count(fuel)
			player.surface.create_entity{
				name = "flying-text",
				position = {player.position.x, player.position.y - 0.5},
				text = {"", "-2 ",game.item_prototypes[fuel].localised_name," (",remain,")"},
				render_player_index = player.index
			}
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
				shadow = rendering.draw_sprite{
					sprite = shadow.."-"..car.direction,
					surface = car.surface,
					target = car
				},
				ring = rendering.draw_circle{
					color = {24,24,24},
					radius = 0.5,
					width = 5, -- +-2/32 of a tile
					filled = false,
					target = car,
					target_offset = {1,-2},
					surface = car.surface,
					players = {player}
				},
				arc = rendering.draw_arc{
					color = {43,227,39},
					min_radius = 0.5-2/32,
					max_radius = 0.5+2/32,
					start_angle = -math.pi/2,
					angle = math.pi*2,
					target = car,
					target_offset = {1,-2},
					surface = car.surface,
					players = {player}
				},
				time = 0,
				position = {car.position.x,car.position.y},
				momentum = {0,0}
			}
			script_data[player.index] = struct
		end
	end
end

---@param event on_player_driving_changed_state
local function onVehicle(event)
	local player = game.players[event.player_index]
	if not player.driving then
		-- check if player is being yeeted and put them back in if so
		local yeet = script_data[player.index]
		if yeet then
			yeet.car.set_driver(player)
		end
	end
end

---@param event on_player_died
local function onDied(event)
	local player = game.players[event.player_index]
	local yeet = script_data[player.index]
	if yeet then
		yeet.car.destroy()
		script_data[player.index] = nil
	end
end

local function onTick()
	for _,struct in pairs(script_data) do
		struct.time = struct.time+1
		local altitude = 5
		if struct.time < 60 then
			altitude = 5*math.sin(struct.time/60*math.pi/2)
		elseif struct.time > 360 then -- fly for 360 ticks, then fall for another 60
			altitude = 5*math.sin((420-struct.time)/60*math.pi/2)
		end

		local driving = struct.player.riding_state
		local acceleration = {0,0}
		if struct.time < 360 then
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
		end
		struct.momentum[1] = struct.momentum[1] * 0.95 + acceleration[1] * 0.04
		struct.momentum[2] = struct.momentum[2] * 0.95 + acceleration[2] * 0.04
		struct.position = {
			struct.position[1] + struct.momentum[1],
			struct.position[2] + struct.momentum[2]
		}
		struct.car.teleport{
			struct.position[1],
			struct.position[2] - altitude
		}
		rendering.set_target(struct.shadow, struct.car, {altitude+1,altitude})
		rendering.set_x_scale(struct.shadow, 1-altitude/40)
		rendering.set_y_scale(struct.shadow, 1-altitude/40)
		rendering.set_angle(struct.arc, math.max(0,1-struct.time/360)*math.pi*2)
		if acceleration[1] ~= 0 or acceleration[2] ~= 0 then
			local angle = math.atan2(-acceleration[2], acceleration[1])
			struct.car.orientation = math.fmod(2 + 0.25 - angle/(math.pi*2), 1)
			local direction = math.floor(struct.car.orientation*8+0.5)%8
			rendering.set_sprite(struct.shadow, shadow.."-"..direction)
		end

		if struct.time >= 420 then
			script_data[struct.player.index] = nil
			local direction = math.floor(struct.car.orientation*8+0.5)%8
			struct.car.destroy()
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
		end
	end
end

return {
	on_init = function()
		global.jetpack_flight = global.jetpack_flight or script_data
	end,
	on_load = function()
		script_data = global.jetpack_flight or script_data
	end,
	events = {
		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_player_died] = onDied,
		[defines.events.on_tick] = onTick,
		["jump"] = onJump
	}
}
