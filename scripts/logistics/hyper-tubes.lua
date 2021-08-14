-- hypertube travel is initiated by entering the pseudo-vehicle
-- this auto-drives the car along the path of the hyper tube until it reaches an exit, ie. an entity with only one connection
-- uses global.hyper_tube to track player -> movement data
-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors

local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local tube = "hyper-tube"
local underground = "underground-hyper-tube"
local entrance = "hyper-tube-entrance"
local car = entrance.."-car"

---@class HyperTubeData
---@field car LuaEntity Car
---@field character LuaEntity Character
---@field entity LuaEntity
---@field entity_last LuaEntity|nil
---@field offset number
---@field direction defines.direction
---@field direction_last defines.direction

---@alias global.hyper_tube table<uint, HyperTubeData>
---@type global.hyper_tube
local script_data = {}
local debounce_error = {}

---@param source LuaEntity
---@return LuaEntity|nil
local function getUndergroundPipeExit(source)
	if source.name ~= underground then return nil end
	for _,exit in pairs(source.neighbours[1]) do
		if source.direction == defines.direction.north and exit.direction == defines.direction.south and source.position.y < exit.position.y then return exit end
		if source.direction == defines.direction.east and exit.direction == defines.direction.west and source.position.x > exit.position.x then return exit end
		if source.direction == defines.direction.south and exit.direction == defines.direction.north and source.position.y > exit.position.y then return exit end
		if source.direction == defines.direction.west and exit.direction == defines.direction.east and source.position.x < exit.position.x then return exit end
	end
	return nil
end

---@param entity LuaEntity
local function onBuilt(entity)
	local launcher = entity.surface.create_entity{
		name = car,
		position = entity.position,
		force = entity.force,
		raise_built = true
	}
	link.register(entity, launcher)
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
	if entity and entity.valid and entity.name == car then
		local travel = script_data
		if player.driving then
			if not travel[player.index] then
				local enter = entity.surface.find_entity(entrance,entity.position)
				if enter.energy == 0 then
					-- must have power
					player.driving = false
					player.teleport(entity.position)
					local exitpos = {
						entity.position.x + vectors[(enter.direction+4)%8][1],
						entity.position.y + vectors[(enter.direction+4)%8][2]
					}
					player.teleport(player.surface.find_non_colliding_position("character",exitpos,0,1,true) or exitpos)
				else
					-- initiate transport
					local character = player.character
					travel[player.index] = {
						car = entity,
						character = character,
						entity = enter,
						entity_last = nil,
						offset = 0.5,
						direction = enter.direction,
						direction_last = enter.direction
					}
					entity.direction = enter.direction
					entity.operable = false
					-- create another car for this entrance
					link.unregister(enter, entity)
					local newcar = enter.surface.create_entity{
						name = car,
						position = enter.position,
						force = enter.force,
						raise_built = true
					}
					link.register(enter, newcar)
				end
			end
		elseif travel[player.index] then
			-- player tried to get out, force them back in!
			travel[player.index].car.set_driver(player)
		end
	end
end

local SPEED = 24/60 -- tiles per tick, must be <1; 24/60 = 24m/s = 86.4kmh
local function onTick()
	local travel = script_data
	if not travel then return end
	for pid,data in pairs(travel) do
		local player = game.players[pid]
		data.offset = data.offset + SPEED
		if not data.entity.valid then
			-- entity was mined while we were in it, abort!
			travel[pid] = nil
			data.car.destroy() -- yeets the player
		else
			if data.offset - SPEED < 0.5 and data.offset >= 0.5 then
				-- crossed the mid-point, so check for next direction
				data.direction_last = data.direction
				if data.entity.name ~= underground then -- undergrounds must continue straight
					local directions = {
						(data.direction + defines.direction.north) % 8,
						(data.direction + defines.direction.east) % 8,
						(data.direction + defines.direction.west) % 8
					}
					-- allow keyboard input to change directions
					if player.riding_state.acceleration == defines.riding.acceleration.accelerating then table.insert(directions, 1, defines.direction.north) end
					if player.riding_state.acceleration == defines.riding.acceleration.reversing then table.insert(directions, 1, defines.direction.south) end
					if player.riding_state.direction == defines.riding.direction.right then table.insert(directions, 1, defines.direction.east) end
					if player.riding_state.direction == defines.riding.direction.left then table.insert(directions, 1, defines.direction.west) end

					data.direction = nil
					for _,direction in pairs(directions) do
						local neighbour = data.entity.surface.find_entities_filtered{
							position = {
								data.entity.position.x + vectors[direction][1],
								data.entity.position.y + vectors[direction][2]
							},
							name = {tube, underground, entrance}
						}[1]
						if neighbour then
							-- directions is in order of preference so if we find one then assume it's valid
							data.direction = direction
							break
						end
					end
					-- direction will remain nil if there is no subsequent entity, indicating an exit
				end
			end
			data.car.teleport({
				data.entity.position.x + (data.offset-0.5) * vectors[data.direction_last][1],
				data.entity.position.y + (data.offset-0.5) * vectors[data.direction_last][2]
			})
			local nextoffset = 1
			if data.offset >= nextoffset and data.entity.name == underground then
				-- if there's no exit then just treat it as a normal tube
				local exit = getUndergroundPipeExit(data.entity)
				if not exit then
					data.direction = nil
				else
					-- max offset will be the length of the underground section plus one
					-- since the ends will always be in a straight line, one of dx or dy will be zero so manhattan distance == euclidean distance
					nextoffset = math.abs(data.entity.position.x - exit.position.x) + math.abs(data.entity.position.y - exit.position.y) + 1
				end
			end
			if data.offset >= nextoffset then
				data.entity_last = data.entity
				if data.entity.name == underground then
					local exit = getUndergroundPipeExit(data.entity)
					if exit then
						data.entity_last = exit
					end
				end

				if data.direction ~= nil then
					-- check if next entity still exists!
					local next = data.entity.surface.find_entities_filtered{
						position = {data.entity.position.x + nextoffset * vectors[data.direction][1], data.entity.position.y + nextoffset * vectors[data.direction][2]},
						name = {tube, underground, entrance}
					}[1]
					if next then
						data.entity = next
						data.offset = data.offset - nextoffset
					else
						data.direction = nil
					end
				end
				if data.direction == nil then -- not "else" because this may change in the above block
					travel[pid] = nil
					local exitpos = {
						data.entity.position.x + vectors[data.direction_last][1]*nextoffset,
						data.entity.position.y + vectors[data.direction_last][2]*nextoffset
					}
					data.car.destroy() -- player gets ejected
					player.character.teleport(player.character.surface.find_non_colliding_position("wooden-chest",exitpos,0,1,true) or exitpos)
				end
			end
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.hyper_tube = global.hyper_tube or script_data
		global.debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		script_data = global.hyper_tube or script_data
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_build = {
		callback = onBuilt,
		filter = {name=entrance}
	},
	events = {
		[defines.events.on_player_driving_changed_state] = onVehicle,
		[defines.events.on_tick] = onTick
	}
}
