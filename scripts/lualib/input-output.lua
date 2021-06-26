-- uses global.io to track structures
local bev = require(modpath.."scripts.lualib.build-events")
local math2d = require("math2d")
local script_data = {
	-- io struct: {target, belt, inserter_left, inserter_right, visual, active, suppressed}
	structures = {}, -- table<base unit number, table<coordinate, io struct>>
	belts = {} -- table<belt unit number, io struct> used for reverse lookup
}

local inserter_name = "loader-inserter"
local belt_tiers = {
	-- map belt/underground names to tiers
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
local loader_belts = {
	-- map tier to loader belt name
	[0] = "loader-conveyor",
	[1] = "loader-conveyor-belt-mk-1",
	[2] = "loader-conveyor-belt-mk-2",
	[3] = "loader-conveyor-belt-mk-3",
	[4] = "loader-conveyor-belt-mk-4",
	[5] = "loader-conveyor-belt-mk-5"
}
local function isLoaderBelt(belt)
	for _,name in pairs(loader_belts) do
		if name == belt.name then return true end
	end
	return false
end

local function getStructsForEntity(entity)
	return script_data.structures[entity.unit_number]
end
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
local function deleteStructsForEntity(entity)
	script_data.structures[entity.unit_number] = nil
end

local function getStructForBelt(belt)
	return script_data.belts[belt.unit_number]
end
local function setStructForBelt(belt, struct)
	script_data.belts[belt.unit_number] = struct
end
local function deleteStructForBelt(belt)
	setStructForBelt(belt, nil)
end

local function addToBufferOrSpillStack(stack, buffer, entity)
	if buffer then
		buffer.insert(stack)
	else
		entity.surface.spill_item_stack(entity.position, stack, true, entity.force, false)
	end
end
local function getItemsFromTransportBelt(belt, buffer)
	-- belts are awkward XD But this will prevent accidentally replenishing items on belts, eg. ammo, and since it's only called on entity mining, it's probably fine
	for i=1,belt.get_max_transport_line_index() do
		local line = belt.get_transport_line(i)
		if #line > 0 then
			for j=1,#line do
				addToBufferOrSpillStack(line[j], buffer, belt)
			end
		end
		line.clear()
	end
end
local function getItemsFromInserter(inserter, buffer)
	if not inserter.held_stack.valid_for_read then return end
	addToBufferOrSpillStack(inserter.held_stack, buffer, inserter)
	inserter.held_stack.clear()
end

local function replaceBelt(belt, tier, buffer)
	-- don't bother if the belt is already the correct type
	if belt.name == loader_belts[tier] then return end

	local struct = getStructForBelt(belt)
	if tier == 0 then
		-- spill the old belt's contents as well as anything in the inserters' hands
		getItemsFromTransportBelt(struct.belt, buffer)
		getItemsFromInserter(struct.inserter_left, buffer)
		getItemsFromInserter(struct.inserter_right, buffer)
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
	struct.inserter_left.active = struct.active and not struct.suppressed
	struct.inserter_right.active = struct.active and not struct.suppressed
end

local function snapNeighbouringLoaderBelts(belt, tier, buffer)
	for _,side in pairs{"inputs","outputs"} do
		-- Due to the "no naked merging" rule, there should only be 0 or 1 neighbours, so we can assume that to be true
		local neighbour = belt.belt_neighbours[side][1]
		if neighbour and isLoaderBelt(neighbour) then
			replaceBelt(neighbour, tier, buffer)
		end
	end
end

local function snapToExistingBelt(belt, direction)
	-- check if a neighbour exists in the given direction, quick-replace the belt if so and return either the existing or newly replaced belt
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
	local belt_left_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,0},direction/8*360))
	local belt_right_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,0},direction/8*360))

	local inserter_left = entity.surface.create_entity{
		name = inserter_name,
		position = entity.position,
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
		position = entity.position,
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
local function destroyConnections(entity, buffer)
	local structs = getStructsForEntity(entity)
	if not structs then return end
	for _,struct in pairs(structs.connections) do
		getItemsFromTransportBelt(struct.belt, buffer)
		deleteStructForBelt(struct.belt)
		struct.belt.destroy()

		getItemsFromInserter(struct.inserter_left, buffer)
		struct.inserter_left.destroy()

		getItemsFromInserter(struct.inserter_right, buffer)
		struct.inserter_right.destroy()

		-- visualisation is linked to the main entity so it gets destroyed automatically
	end
	deleteStructsForEntity(entity)
end

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
local function isEnabled(entity)
	local structs = getStructsForEntity(entity)
	assert(structs, "Call to isEnabled on "..entity.name.." at "..entity.position.x..","..entity.position.y.." failed: no registration")
	return structs.active
end

local function onBuiltOrRotated(event)
	-- building and rotating both have the same effects!
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	local tier = belt_tiers[entity.name]
	if not tier then return end -- not a known belt type
	snapNeighbouringLoaderBelts(entity, tier)
end

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
