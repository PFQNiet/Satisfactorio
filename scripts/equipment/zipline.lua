-- zipline travel is initiated by pressing Jump near a wire
-- this auto-drives a fake car along the wire
-- direction keys can change direction when you arrive at a pole, and Enter exits the car to end travel (or end automatically when arriving at a dead end)
-- uses global.zipline to track player -> movement data

local poletype = "electric-pole"
local item = "zipline"
local vehicle = item.."-flying"
local shadow = item.."-flying-shadow"

---@class ZiplineData
---@field player LuaPlayer
---@field car LuaEntity Car
---@field shadow uint64
---@field position Position
---@field direction number Angle in radians
---@field source LuaEntity ElectricPole
---@field target LuaEntity ElectricPole
---@field timeout uint If this somehow reaches 0, abort zipping

---@alias global.zipline table<uint, ZiplineData>
---@type global.zipline
local script_data = {}

local math2d = require("math2d")
---@param p Position
---@param u Position
---@param v Position
---@return number Distance
---@return Position Projection
---@return number Progress along line (0-1)
local function distance_to_line_segment(p, u, v)
	p = math2d.position.ensure_xy(p)
	u = math2d.position.ensure_xy(u)
	v = math2d.position.ensure_xy(v)
	local A = p.x - u.x
	local B = p.y - u.y
	local C = v.x - u.x
	local D = v.y - u.y

	local dot = A * C + B * D
	local len_sq = C * C + D * D
	local param = len_sq == 0 and 0 or math.max(0,math.min(1,dot/len_sq))
	local projection = {
		x = u.x + param * C,
		y = u.y + param * D
	}
	local dx = p.x - projection.x
	local dy = p.y - projection.y
	return math.sqrt(dx*dx + dy*dy), projection, param
end

-- Scan outwards from the given position until enough entities are found
---@param surface LuaSurface
---@param filters LuaSurface.find_entities_filtered_param
---@param limit number
---@return LuaEntity[]
local function findNClosest(surface, filters, limit)
	-- "limit" may be exceeded if increasing the radius crosses the threshold, but whatever it's good enough for this
	local entities = surface.find_entities_filtered(filters)
	if #entities <= limit then return entities end

	-- if I could be bothered, I'd make this into a binary search but the difference between O(n) and O(log n) is basically nil when n is so small...
	for r=1,filters.radius or 10,1 do
		filters.radius = r
		entities = surface.find_entities_filtered(filters)
		if #entities >= limit then return entities end
	end
	-- reached radius limit without finding enough entities, so return the ones that were found (if any)
	return entities
end

local function onJump(event)
	local player = game.players[event.player_index]
	local inventory = player.get_inventory(defines.inventory.character_armor)
	if not inventory then return end
	local armour = inventory[1]
	if armour.valid_for_read and armour.name == item and not player.driving then
		-- find a wire that passes close enough overhead
		local nearby_poles = findNClosest(player.surface, {
			type = poletype,
			position = player.position,
			radius = 16
		}, 5)
		local closest = {distance = 2} -- don't snap to a wire more than 2 tiles away
		local pos = math2d.position.ensure_xy(player.position)
		pos.y = pos.y - 3 -- approximate height of the wire over the player's head
		for _,pole in pairs(nearby_poles) do
			local neighbours = pole.neighbours.copper
			for _,neighbour in pairs(neighbours) do
				if pole.unit_number > neighbour.unit_number then -- deduplicate search
					local distance, projection = distance_to_line_segment(player.position, pole.position, neighbour.position)
					if distance < closest.distance then
						closest.pole1 = pole
						closest.pole2 = neighbour
						closest.distance = distance
						closest.point = projection
					end
				end
			end
		end
		if not closest.pole1 then
			player.surface.create_entity{
				name = "flying-text",
				position = player.position,
				text = {"message.zipline-no-wire"},
				render_player_index = player.index
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
		else
			-- determine direction of the wire
			local wiredir = math.atan2(closest.pole1.position.y - closest.pole2.position.y, closest.pole2.position.x - closest.pole1.position.x)
			local source = closest.pole1
			local target = closest.pole2
			-- if player is facing the other way, then go the other way
			if player.character then
				local chardir = math.pi/2 - player.character.direction / 8 * math.pi*2
				local delta = math.abs(math.atan2(math.sin(chardir-wiredir), math.cos(chardir-wiredir)))
				if delta > math.pi/2 then
					wiredir = wiredir < math.pi and wiredir+math.pi or wiredir-math.pi
					source = closest.pole2
					target = closest.pole1
				end
			end
			-- spawn a car and get into it
			local car = player.surface.create_entity{
				name = vehicle,
				position = closest.point,
				force = player.force,
				direction = (10-math.floor(wiredir / math.pi * 4 + 0.5)) % 8,
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
				position = {car.position.x,car.position.y},
				direction = wiredir,
				source = source,
				target = target,
				timeout = 150
			}
			script_data[player.index] = struct
		end
	end
end

---@param event on_player_driving_changed_state
local function onVehicle(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity and entity.valid and entity.name == vehicle then
		local data = script_data[player.index]
		if not player.driving and data then
			player.teleport(player.surface.find_non_colliding_position("character", data.position, 2, 0.1, false) or data.position)
			data.car.destroy()
			script_data[player.index] = nil
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

local SPEED = 12/60 -- tiles per tick, must be <1; 12/60 = 12m/s = 43.2kmh
local function onTick()
	for _,data in pairs(script_data) do
		local player = data.player
		-- data: {player, car, shadow, position, direction, source, target, timeout}
		data.timeout = data.timeout - 1
		if not (data.source.valid and data.target.valid) or data.timeout <= 0 then
			-- someone mined the pole, or something went wrong
			script_data[player.index] = nil
			data.car.destroy() -- drop the player
			player.teleport(player.surface.find_non_colliding_position("character", data.position, 2, 0.1, false) or data.position)
		else
			data.position = math2d.position.add(data.position, {SPEED * math.cos(data.direction), -SPEED * math.sin(data.direction)})
			local offset = select(3, distance_to_line_segment(data.position, data.source.position, data.target.position))
			if offset >= 1 then
				-- reached target pole, establish next pole and continue if one exists
				local wanted_direction = data.direction
				if player.riding_state.acceleration == defines.riding.acceleration.accelerating then
					if player.riding_state.direction == defines.riding.direction.right then wanted_direction = math.pi/4 -- northeast
					elseif player.riding_state.direction == defines.riding.direction.left then wanted_direction = math.pi*3/4 -- northwest
					else wanted_direction = math.pi/2 -- north
					end
				elseif player.riding_state.acceleration == defines.riding.acceleration.reversing then
					if player.riding_state.direction == defines.riding.direction.right then wanted_direction = math.pi*7/4 -- southeast
					elseif player.riding_state.direction == defines.riding.direction.left then wanted_direction = math.pi*5/4 -- southwest
					else wanted_direction = math.pi*3/2 -- south
					end
				else
					if player.riding_state.direction == defines.riding.direction.right then wanted_direction = 0 -- east
					elseif player.riding_state.direction == defines.riding.direction.left then wanted_direction = math.pi -- west
					else wanted_direction = data.direction -- unchanged
					end
				end
				local neighbours = data.target.neighbours.copper
				local closest = {delta = math.pi-0.01} -- within a (180-epsilon)-degree angle of the requested direction
				for _,neighbour in pairs(neighbours) do
					local wiredir = math.atan2(data.target.position.y - neighbour.position.y, neighbour.position.x - data.target.position.x)
					local delta = math.abs(math.atan2(math.sin(wanted_direction-wiredir), math.cos(wanted_direction-wiredir)))
					if delta < closest.delta then
						closest.pole = neighbour
						closest.direction = wiredir
						closest.delta = delta
					end
				end
				if not closest.pole then
					-- no poles found, drop off here
					script_data[player.index] = nil
					data.car.destroy()
					-- add a little more position to overshoot the pole
					data.position = math2d.position.add(data.position, {0.4 * math.cos(data.direction), -0.4 * math.sin(data.direction)})
					player.teleport(player.surface.find_non_colliding_position("character", data.position, 2, 0.1, false) or data.position)
				else
					data.source = data.target
					data.target = closest.pole
					data.direction = closest.direction
					-- determine how far we over-shot by and place position on the new line at the appropriate offset
					local overshoot = math2d.position.distance(data.position, data.source.position)
					data.position = math2d.position.add(data.source.position, {overshoot*math.cos(data.direction), -overshoot*math.sin(data.direction)})
					offset = select(3,distance_to_line_segment(data.position, data.source.position, data.target.position))
					data.timeout = 150
					-- update orientation of "car" and shadow
					data.car.orientation = math.fmod(2 + 0.25-data.direction/(math.pi*2), 1)
					local shadowdir = math.floor(data.car.orientation*8+0.5)%8
					rendering.set_sprite(data.shadow, shadow.."-"..shadowdir)
				end
			end
			if data.car.valid then
				-- car would be destroyed if we reached the end of the line
				local height = 3-0.75*math.sin(offset*math.pi) - 1.5
				data.car.teleport{
					data.position.x,
					data.position.y - height
				}
				rendering.set_target(data.shadow, data.car, {height+1,height})
				rendering.set_x_scale(data.shadow, 1-height/40)
				rendering.set_y_scale(data.shadow, 1-height/40)
			end
		end
	end
end

return {
	on_init = function()
		global.zipline = global.zipline or script_data
	end,
	on_load = function()
		script_data = global.zipline or script_data
	end,
	events = {
		["jump"] = onJump,
		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_player_died] = onDied,
		[defines.events.on_tick] = onTick
	}
}
