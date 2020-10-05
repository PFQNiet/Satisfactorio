-- hypertube travel is initiated by entering the pseudo-vehicle
-- this should set control to ghost, spectator to true, and pan the view along the path of the hyper tube until it reaches an exit, ie. an entity with only one connection
-- uses global['hyper-tube-travel'] to track player -> movement data
-- uses global['hyper-tube-error-debounce'] to track force -> last error tick to de-duplicate placement errors

local tube = "hyper-tube"
local underground = "underground-hyper-tube"
local entrance = "hyper-tube-entrance"
local car = entrance.."-car"

local function getUndergroundPipeExit(entrance)
	if entrance.name ~= underground then return nil end
	for _,exit in pairs(entrance.neighbours[1]) do
		if entrance.direction == defines.direction.north and exit.direction == defines.direction.south and entrance.position.y < exit.position.y then return exit end
		if entrance.direction == defines.direction.east and exit.direction == defines.direction.west and entrance.position.x > exit.position.x then return exit end
		if entrance.direction == defines.direction.south and exit.direction == defines.direction.north and entrance.position.y > exit.position.y then return exit end
		if entrance.direction == defines.direction.west and exit.direction == defines.direction.east and entrance.position.x < exit.position.x then return exit end
	end
	return nil
end
local function isValidHyperTube(entity)
	-- ensure this entity, and its neighbours, have fewer than 3 neighbours
	local neighbours = entity.neighbours
	if #neighbours[1] > 2 then return false end
	for _,other in pairs(neighbours[1]) do
		if #other.neighbours[1] > 2 then return false end
	end
	return true
end
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == tube or entity.name == underground or entity.name == entrance then
		if not isValidHyperTube(entity) then
			local player = entity.last_user
			player.insert{name=entity.name,count=1}
			if not global['hyper-tube-error-debounce'] then global['hyper-tube-error-debounce'] = {} end
			if not global['hyper-tube-error-debounce'][player.force.index] or global['hyper-tube-error-debounce'][player.force.index] < event.tick then
				player.surface.create_entity{
					name = "flying-text",
					position = entity.position,
					text = {"message.hyper-tube-no-junction"},
					render_player_index = player.index
				}
				player.play_sound{
					path = "utility/cannot_build"
				}
				global['hyper-tube-error-debounce'][player.force.index] = event.tick + 60
			end
			entity.destroy()
			return
		end
	end
	if entity.name == entrance then
		-- known valid due to return statement above
		entity.surface.create_entity{
			name = car,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
	end
end
local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == entrance then
		-- remove the vehicle
		local box = entity.surface.find_entity(car, entity.position)
		if box and box.valid then
			box.destroy()
		end
	end
end
local function onRotated(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == tube or entity.name == underground or entity.name == entrance then
		if not isValidHyperTube(entity) then
			event.entity.direction = event.previous_direction
			local player = game.players[event.player_index]
			player.surface.create_entity{
				name = "flying-text",
				position = entity.position,
				text = {"message.hyper-tube-no-junction"},
				render_player_index = player.index
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
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
	if entity and entity.valid and entity.name == car then
		if player.driving then
			local enter = entity.surface.find_entity(entrance,entity.position)
			if entity.get_driver() ~= player.character or enter.energy == 0 then
				-- eject passengers, driver only; must have power
				player.driving = false
				local exitpos = {
					entity.position.x + vectors[(enter.direction+4)%8][1],
					entity.position.y + vectors[(enter.direction+4)%8][2]
				}
				player.character.teleport(player.character.surface.find_non_colliding_position("wooden-chest",exitpos,0,1,true) or exitpos)
			else
				-- initiate transport
				local character = player.character
				player.disassociate_character(character)
				if not global['hyper-tube-travel'] then global['hyper-tube-travel'] = {} end
				global['hyper-tube-travel'][player.index] = {
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
				enter.surface.create_entity{
					name = car,
					position = enter.position,
					force = enter.force,
					raise_built = true
				}
			end
		elseif global['hyper-tube-travel'] and global['hyper-tube-travel'][player.index] then
			-- player tried to get out, force them back in!
			global['hyper-tube-travel'][player.index].car.set_driver(player.character)
		end
	end
end
local SPEED = 0.25 -- tiles per tick, so 0.25 = 15 tiles per second
local function onTick(event)
	if not global['hyper-tube-travel'] then return end
	for pid,data in pairs(global['hyper-tube-travel']) do
		local player = game.players[pid]
		data.offset = data.offset + SPEED
		if not data.entity.valid then
			-- entity was mined while we were in it, abort!
			data.car.destroy() -- yeets the player
			global['hyper-tube-travel'][pid] = nil
		else
			if data.offset - SPEED < 0.5 and data.offset >= 0.5 then
				-- crossed the mid-point, so check for next direction
				data.direction_last = data.direction
				if data.entity.name ~= underground then
					data.direction = nil
					for _,neighbour in pairs(data.entity.neighbours[1]) do
						if neighbour ~= data.entity_last then
							-- there can be only one so if we find one then assume it's valid
							if data.entity.position.y > neighbour.position.y then data.direction = defines.direction.north
							elseif data.entity.position.x < neighbour.position.x then data.direction = defines.direction.east
							elseif data.entity.position.y < neighbour.position.y then data.direction = defines.direction.south
							else data.direction = defines.direction.west
							end
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
				data.entity.minable = true
				data.entity_last = data.entity
				if data.entity.name == underground then
					local exit = getUndergroundPipeExit(data.entity)
					if exit then
						exit.minable = true
						data.entity_last = exit
					end
				end

				if data.direction ~= nil then
					-- check if next entity still exists!
					local next = data.entity.surface.find_entities_filtered{
						position = {data.entity.position.x + nextoffset * vectors[data.direction][1], data.entity.position.y + nextoffset * vectors[data.direction][2]},
						name = {tube, underground, entrance}
					}
					if #next > 0 then
						data.entity = next[1]
						next.minable = nil
						if next.name == underground then
							local exit = getUndergroundPipeExit(next)
							if exit then exit.minable = false end
						end
						data.offset = data.offset - nextoffset
					else
						data.direction = nil
					end
				end
				if data.direction == nil then -- not "else" because this may change in the above block
					local exitpos = {
						data.entity.position.x + vectors[data.direction_last][1],
						data.entity.position.y + vectors[data.direction_last][2]
					}
					data.car.destroy() -- player gets ejected
					player.character.teleport(player.character.surface.find_non_colliding_position("wooden-chest",exitpos,0,1,true) or exitpos)
					global['hyper-tube-travel'][pid] = nil
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
