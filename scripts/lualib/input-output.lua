---@class MachineConnection
---@field target LuaEntity
---@field belt LuaEntity TransportBelt
---@field inserter_left LuaEntity Inserter
---@field inserter_right LuaEntity Inserter
---@field visual uint64 Rendering arrow/line
---@field active boolean Activity toggled by there being a valid belt connected

---@class MachineConnectionList
---@field active boolean
---@field connections MachineConnection[]

local bev = require(modpath.."scripts.lualib.build-events")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local math2d = require("math2d")

---@class global.io
---@field structures table<uint, MachineConnectionList>
---@field belts table<uint, MachineConnection> reverse lookup
local script_data = {
	structures = {},
	belts = {}
}

local vectors = {
	[defines.direction.north] = {
		left = {-1,0},
		right = {1,0}
	},
	[defines.direction.east] = {
		left = {0,-1},
		right = {0,1}
	},
	[defines.direction.south] = {
		left = {1,0},
		right = {-1,0}
	},
	[defines.direction.west] = {
		left = {0,1},
		right = {0,-1}
	}
}

local inserter_name = "loader-inserter"
-- map belt/underground names to tiers
local belt_tiers = {
	["conveyor-belt-mk-1"] = 1,
	["conveyor-lift-mk-1"] = 1,
	["conveyor-belt-mk-2"] = 2,
	["conveyor-lift-mk-2"] = 2,
	["conveyor-belt-mk-3"] = 3,
	["conveyor-lift-mk-3"] = 3,
	["conveyor-belt-mk-4"] = 4,
	["conveyor-lift-mk-4"] = 4,
	["conveyor-belt-mk-5"] = 5,
	["conveyor-lift-mk-5"] = 5
}
-- map tier to loader belt name
local loader_belts = {
	[0] = "loader-conveyor",
	[1] = "loader-conveyor-belt-mk-1",
	[2] = "loader-conveyor-belt-mk-2",
	[3] = "loader-conveyor-belt-mk-3",
	[4] = "loader-conveyor-belt-mk-4",
	[5] = "loader-conveyor-belt-mk-5"
}
---@param belt LuaEntity
local function isLoaderBelt(belt)
	for _,name in pairs(loader_belts) do
		if name == belt.name then return true end
	end
	return false
end

---@param entity LuaEntity
local function getStructsForEntity(entity)
	return script_data.structures[entity.unit_number]
end
---@param entity LuaEntity
---@param struct MachineConnection
local function addStructForEntity(entity, struct)
	local obj = getStructsForEntity(entity)
	if not obj then
		obj = {
			active = true,
			connections = {}
		}
		script_data.structures[entity.unit_number] = obj
	end
	table.insert(obj.connections, struct)
end
---@param entity LuaEntity
local function deleteStructsForEntity(entity)
	script_data.structures[entity.unit_number] = nil
end

---@param belt LuaEntity
local function getStructForBelt(belt)
	return script_data.belts[belt.unit_number]
end
---@param belt LuaEntity
---@param struct MachineConnection
local function setStructForBelt(belt, struct)
	script_data.belts[belt.unit_number] = struct
end
---@param belt LuaEntity
local function deleteStructForBelt(belt)
	setStructForBelt(belt, nil)
end

---@param belt LuaEntity
---@param tier number
---@param buffer LuaInventory|nil
local function replaceBelt(belt, tier, buffer)
	-- don't bother if the belt is already the correct type
	if belt.name == loader_belts[tier] then return end

	local struct = getStructForBelt(belt)
	if tier == 0 then
		-- spill the old belt's contents as well as anything in the inserters' hands
		getitems.belt(struct.belt, buffer)
		getitems.inserter(struct.inserter_left, buffer)
		getitems.inserter(struct.inserter_right, buffer)
	end
	deleteStructForBelt(belt)
	struct.belt = belt.surface.create_entity{
		name = loader_belts[tier],
		position = belt.position,
		direction = belt.direction,
		force = belt.force,
		raise_built = true,
		fast_replace = true,
		spill = false
	}
	setStructForBelt(struct.belt, struct)
	struct.active = tier > 0
	local parent_active = getStructsForEntity(struct.target).active
	struct.inserter_left.active = struct.active and parent_active
	struct.inserter_right.active = struct.active and parent_active
end

---@param belt LuaEntity
---@param tier number
---@param buffer LuaInventory|nil
local function snapNeighbouringLoaderBelts(belt, tier, buffer)
	for _,side in pairs{"inputs","outputs"} do
		-- Due to the "no naked merging" rule, there should only be 0 or 1 neighbours, so we can assume that to be true
		local neighbour = belt.belt_neighbours[side][1]
		if neighbour and isLoaderBelt(neighbour) then
			replaceBelt(neighbour, tier, buffer)
		end
	end
end

-- check if a neighbour exists in the given direction, quick-replace the belt if so and return either the existing or newly replaced belt
---@param belt LuaEntity
---@param direction '"inputs"'|'"outputs"'
---@return LuaEntity
local function snapToExistingBelt(belt, direction)
	-- can assume just one neighbour since only one edge of the belt is exposed to the player
	local neighbour = belt.belt_neighbours[direction][1]
	if not neighbour then return belt end
	if isLoaderBelt(neighbour) then return belt end -- don't allow adjacent loader belts (daisy-chaining)
	if #neighbour.belt_neighbours.inputs > 1 then return belt end -- disallow side-loading

	local tier = belt_tiers[neighbour.name]
	if not tier then return belt end -- not a known snappable belt, should probably inform the player of this
	return belt.surface.create_entity{
		name = loader_belts[tier],
		position = belt.position,
		direction = belt.direction,
		force = belt.force,
		raise_built = true,
		fast_replace = true,
		spill = false
	}
end

-- Add an input or output to the given machine
---@param entity LuaEntity
---@param offset Position Relative to the entity facing North
---@param mode '"input"'|'"output"'
---@param target LuaEntity|nil Child entity to target
---@param direction defines.direction Default to North
---@return MachineConnection
local function addConnection(entity, offset, mode, target, direction)
	assert(mode == "input" or mode == "output", "Invalid mode "..mode..", expected 'input' or 'output'")

	-- offset is given based on building facing north, so rotate it according to the entity's actual rotation
	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	local position = math2d.position.add(entity.position, offset)

	-- by default all inputs and outputs go north, but may be rotated
	direction = (entity.direction + (direction or defines.direction.north)) % 8

	-- create inactive belt first, then snap based on existing neighbours
	local belt = entity.surface.create_entity{
		name = loader_belts[0],
		position = position,
		direction = direction,
		force = entity.force,
		raise_built = true
	}
	belt = snapToExistingBelt(belt, mode.."s")
	-- if it did in fact snap, set this to be active
	local isactive = belt.name ~= loader_belts[0]

	local target_position = (target or entity).position
	local belt_left_position = math2d.position.add(position, math2d.position.divide_scalar(vectors[direction].left,4))
	local belt_right_position = math2d.position.add(position, math2d.position.divide_scalar(vectors[direction].right,4))
	-- Input: to ensure both lanes are pulled from equally, place input inserters on either side of the belt
	-- Output: to ensure multiple outputs pull equally, place output inserters on the target so they're on the same chunk
	local inserter_left_position = mode == "input" and math2d.position.add(position, vectors[direction].left) or target_position
	local inserter_right_position = mode == "input" and math2d.position.add(position, vectors[direction].right) or target_position

	local inserter_left = entity.surface.create_entity{
		name = inserter_name,
		position = inserter_left_position,
		direction = direction,
		force = entity.force,
		raise_built = true
	}
	inserter_left.pickup_position = mode == "input" and belt_left_position or target_position
	inserter_left.drop_position = mode == "input" and target_position or belt_left_position
	inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
	inserter_left.active = isactive

	local inserter_right = entity.surface.create_entity{
		name = inserter_name,
		position = inserter_right_position,
		direction = direction,
		force = entity.force,
		raise_built = true
	}
	inserter_right.pickup_position = mode == "input" and belt_right_position or target_position
	inserter_right.drop_position = mode == "input" and target_position or belt_right_position
	inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
	inserter_right.active = isactive

	local sprite = mode == "input" and "indication_line" or "indication_arrow"
	local visual = rendering.draw_sprite{
		sprite = "utility."..sprite,
		orientation = direction/8,
		render_layer = "arrow",
		target = entity,
		target_offset = {offset.x, offset.y},
		surface = entity.surface,
		only_in_alt_mode = true
	}

	-- pack it all up nice
	local struct = {
		target = entity,
		belt = belt,
		inserter_left = inserter_left,
		inserter_right = inserter_right,
		active = isactive,
		visual = visual
	}
	addStructForEntity(entity, struct)
	setStructForBelt(belt, struct)
	return struct
end

-- clean up all entities involved in the entity's IO, putting any items into the provided buffer (or spilling them)
---@param entity LuaEntity
---@param buffer LuaInventory
local function destroyConnections(entity, buffer)
	local structs = getStructsForEntity(entity)
	if not structs then return end
	for _,struct in pairs(structs.connections) do
		getitems.belt(struct.belt, buffer)
		deleteStructForBelt(struct.belt)
		struct.belt.destroy()

		getitems.inserter(struct.inserter_left, buffer)
		struct.inserter_left.destroy()

		getitems.inserter(struct.inserter_right, buffer)
		struct.inserter_right.destroy()

		-- visualisation is linked to the main entity so it gets destroyed automatically
	end
	deleteStructsForEntity(entity)
end

---@param entity LuaEntity
---@param enable boolean
local function toggleConnections(entity, enable)
	local structs = getStructsForEntity(entity)
	assert(structs, "Call to toggle on "..entity.name.." at "..entity.position.x..","..entity.position.y.." failed: no registration")
	if enable == nil then enable = not structs.active end
	structs.active = enable
	for _,struct in pairs(structs.connections) do
		-- both the structure as a whole and this individual connection must be active
		struct.inserter_left.active = structs.active and struct.active
		struct.inserter_right.active = structs.active and struct.active
	end
end
---@param entity LuaEntity
local function isEnabled(entity)
	local structs = getStructsForEntity(entity)
	assert(structs, "Call to isEnabled on "..entity.name.." at "..entity.position.x..","..entity.position.y.." failed: no registration")
	return structs.active
end

---@param event on_build|on_player_rotated_entity
local function onBuiltOrRotated(event)
	-- building and rotating both have the same effects!
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	local tier = belt_tiers[entity.name]
	if not tier then return end -- not a known belt type
	snapNeighbouringLoaderBelts(entity, tier)
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end

	-- if the entity had any IO connections, those will be cleaned up
	destroyConnections(entity, event.buffer)

	local tier = belt_tiers[entity.name]
	if tier then
		-- disconnect neighbouring loaders
		snapNeighbouringLoaderBelts(entity, 0, event.buffer)
		return
	end
end

return {
	addConnection = addConnection,
	getConnections = getStructsForEntity,
	toggle = toggleConnections,
	isEnabled = isEnabled,
	lib = bev.applyBuildEvents{
		on_init = function()
			global.io = global.io or script_data
		end,
		on_load = function()
			script_data = global.io or script_data
		end,
		on_build = onBuiltOrRotated,
		on_destroy = onRemoved,
		events = {
			[defines.events.on_player_rotated_entity] = onBuiltOrRotated
		}
	}
}
