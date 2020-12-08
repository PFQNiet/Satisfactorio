-- with parachute equipped, player can press J to jump from the topside of a cliff to the bottom side
-- cliff must be facing away from the player (same direction, or 45 degrees off) and within 4 tiles - the jump itself is 6 tiles
-- uses global['parachute-flight'] to track player > {fake car, shadow, flight time}
local math2d = require("math2d")
local string = require(modpath.."scripts.lualib.string")

local item = "parachute"
local vehicle = item.."-flying"
local shadow = item.."-flying-shadow"

local script_data = {}

local function onJump(event)
	local player = game.players[event.player_index]
	local inventory = player.get_inventory(defines.inventory.character_armor)
	if not inventory then return end
	local armour = inventory[1]
	if armour.valid_for_read and armour.name == item and player.character and not player.driving then
		-- check for a cliff in front of the player
		local cliffs = player.surface.find_entities_filtered{
			type = "cliff",
			position = math2d.position.add(player.position, math2d.position.rotate_vector({0,-1.5}, player.character.direction*45)),
			radius = 2
		}
		local cliff = nil
		local direction
		local dirmap = {
			none = {0,0},
			north = {0,-1},
			east = {1,0},
			south = {0,1},
			west = {-1,0}
		}
		for _,candidate in pairs(cliffs) do
			local dirspec = string.split(candidate.cliff_orientation, "-")
			local dx = dirmap[dirspec[3]][1] - dirmap[dirspec[1]][1]
			local dy = dirmap[dirspec[1]][2] - dirmap[dirspec[3]][2]
			local angle = math.floor((12-math.atan2(dy,dx)/math.pi*4)%8+0.01)
			if angle == player.character.direction or (angle+1%8) == player.character.direction or (angle+7)%8 == player.character.direction then
				cliff = candidate
				direction = angle
				break
			end
		end

		if not cliff then
			player.surface.create_entity{
				name = "flying-text",
				position = player.position,
				text = {"message.parachute-no-cliff"},
				render_player_index = player.index
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
		else
			inventory.remove{name=item,count=1}
			-- spawn a car and get into it
			local car = player.surface.create_entity{
				name = vehicle,
				position = player.position,
				force = player.force,
				direction = player.character and player.character.direction or defines.direction.north,
				raise_built = true
			}
			car.set_driver(player)
			local struct = {
				player = player,
				car = car,
				shadow = rendering.draw_sprite{
					sprite = shadow.."-"..direction,
					surface = car.surface,
					target = car
				},
				time = 0,
				position = car.position,
				direction = direction
			}
			script_data[player.index] = struct
		end
	end
end

local function onVehicle(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if not player.driving then
		-- check if player is being yeeted and put them back in if so
		local yeet = script_data[player.index]
		if yeet then
			yeet.car.set_driver(player)
		end
	end
end

local function onTick(event)
	for pid,struct in pairs(script_data) do
		struct.time = struct.time+1

		local altitude = 2*math.sin(struct.time/60*math.pi)
		struct.position = math2d.position.add(struct.position, math2d.position.rotate_vector({0,-4/60}, struct.direction*45))

		struct.car.teleport{
			struct.position.x,
			struct.position.y-altitude
		}
		rendering.set_target(struct.shadow, struct.car, {altitude+1,altitude})
		rendering.set_x_scale(struct.shadow, 1-altitude/40)
		rendering.set_y_scale(struct.shadow, 1-altitude/40)

		if struct.time >= 60 then
			script_data[struct.player.index] = nil
			struct.car.destroy()
			struct.player.teleport(struct.position)
			local character = struct.player.character
			if character then
				-- move the character aside so it is out of the way of its own collision check
				character.teleport({struct.position.x-5, struct.position.y})
				-- then find an empty space at the target
				character.teleport(character.surface.find_non_colliding_position("character",struct.position,0,0.05))
			end
		end
	end
end

return {
	on_init = function()
		global.parachute_flight = global.parachute_flight or script_data
	end,
	on_load = function()
		script_data = global.parachute_flight or script_data
	end,
	events = {
		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_tick] = onTick,
		["jump"] = onJump
	}
}
