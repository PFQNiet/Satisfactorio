local miner = "miner-mk-1"
local box = "miner-mk-1-box"

local miner_box_offsets = {
	[defines.direction.north] = {0,-4},
	[defines.direction.east] = {4,0},
	[defines.direction.south] = {0,4},
	[defines.direction.west] = {-4,0}
}
local function getMinerBoxPosition(miner)
	return {
		(miner.position[1] or miner.position.x) + miner_box_offsets[miner.direction][1],
		(miner.position[2] or miner.position.y) + miner_box_offsets[miner.direction][2]
	}
end
local miner_loader_offsets = {
	[defines.direction.north] = {0,-6},
	[defines.direction.east] = {6,0},
	[defines.direction.south] = {0,6},
	[defines.direction.west] = {-6,0}
}
local function getMinerLoaderPosition(miner)
	return {
		(miner.position[1] or miner.position.x) + miner_loader_offsets[miner.direction][1],
		(miner.position[2] or miner.position.y) + miner_loader_offsets[miner.direction][2]
	}
end
local rotations = {
	[defines.direction.north] = {0,-1},
	[defines.direction.east] = {1,0},
	[defines.direction.south] = {0,1},
	[defines.direction.west] = {-1,0}
}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == miner then
		-- spawn a box for this drill
		local store = entity.surface.create_entity{
			name = box,
			position = getMinerBoxPosition(entity),
			force = entity.force,
			raise_built = true
		}
		-- an output belt
		local belt = entity.surface.create_entity{
			name = "loader-conveyor",
			position = getMinerLoaderPosition(entity),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		-- and a pair of inserters
		local inserter_left = entity.surface.create_entity{
			name = "loader-inserter",
			position = getMinerLoaderPosition(entity),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		inserter_left.pickup_position = {
			inserter_left.position.x + rotations[entity.direction][1]*-1,
			inserter_left.position.y + rotations[entity.direction][2]*-1
		}
		inserter_left.drop_position = {
			inserter_left.position.x + rotations[entity.direction][1]*0.25 + rotations[entity.direction][2]*0.25,
			inserter_left.position.y + rotations[entity.direction][1]*0.25 + rotations[entity.direction][2]*0.25
		}
		inserter_left.operable = false
		inserter_left.minable = false
		inserter_left.destructible = false
		local inserter_right = entity.surface.create_entity{
			name = "loader-inserter",
			position = getMinerLoaderPosition(entity),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		inserter_right.pickup_position = inserter_left.pickup_position
		inserter_right.drop_position = {
			inserter_right.position.x + rotations[entity.direction][1]*0.25 + rotations[entity.direction][2]*-0.25,
			inserter_right.position.y+ rotations[entity.direction][1]*-0.25 + rotations[entity.direction][2]*0.25
		}
		inserter_right.operable = false
		inserter_right.minable = false
		inserter_right.destructible = false
		-- make the drill intangible
		entity.operable = false
		entity.minable = false
		entity.destructible = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == box then
		-- find the drill that should be right here
		local drill = entity.surface.find_entity(miner,entity.position)
		if not drill or not drill.valid then
			game.print("Couldn't find the drill")
			return
		end
		-- and the belt
		local belt = entity.surface.find_entity("loader-conveyor",getMinerLoaderPosition(drill))
		if not belt or not belt.valid then
			game.print("Couldn't find belt")
		else
			belt.destroy()
		end
		-- and the loader-inserters
		local inserter1 = entity.surface.find_entity("loader-inserter",getMinerLoaderPosition(drill))
		if not inserter1 or not inserter1.valid then
			game.print("Couldn't find inserter 1")
		else
			inserter1.destroy()
		end
		local inserter2 = entity.surface.find_entity("loader-inserter",getMinerLoaderPosition(drill))
		if not inserter2 or not inserter2.valid then
			game.print("Couldn't find inserter 2")
		else
			inserter2.destroy()
		end
		drill.destroy()
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
		[defines.events.script_raised_destroy] = onRemoved
	}
}
