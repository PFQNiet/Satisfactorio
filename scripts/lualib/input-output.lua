-- uses global.io to track structures based on unit_number > {belt, inserter1, inserter2, indicator}
local math2d = require("math2d")
local string = require(modpath.."scripts.lualib.string")
local script_data = {}

local function addToBufferOrSpillStack(stack, entity, buffer)
	if buffer then
		buffer.insert(stack)
	else
		entity.surface.spill_item_stack(entity.position, stack, true, entity.force, false)
	end
end
local function addToBufferOrSpillTransportBelt(belt, buffer)
	-- belts are awkward XD But this will prevent accidentally replenishing items on belts, eg. ammo, and since it's only called on entity mining, it's probably fine
	for i=1,belt.get_max_transport_line_index() do
		local line = belt.get_transport_line(i)
		if #line > 0 then
			for j=1,#line do
				addToBufferOrSpillStack(line[j], belt, buffer)
			end
		end
		line.clear()
	end
end

local function findStructureFromBelt(belt)
	local candidates = belt.surface.find_entities_filtered{
		position = belt.position,
		collision_mask = "object-layer"
	}
	for _,entity in pairs(candidates) do
		if script_data[entity.unit_number] then
			for _,struct in pairs(script_data[entity.unit_number]) do
				if struct.belt == belt then
					return struct
				end
			end
			break -- there should be only one entity with IO at this position!
		end
	end
	-- it should always exist - not existing is an error state
end
local function replaceBelt(entity, type, buffer)
	local struct = findStructureFromBelt(entity)
	if type == "loader-conveyor" then
		-- spill the old belt's contents as well as anything in the inserters' hands
		addToBufferOrSpillTransportBelt(entity, buffer)
		local left = struct.inserter_left.held_stack
		if left and left.valid_for_read then
			addToBufferOrSpillStack(left, entity, buffer)
			left.clear()
		end
		local right = struct.inserter_left.held_stack
		if right and right.valid_for_read then
			addToBufferOrSpillStack(right, entity, buffer)
			right.clear()
		end
	
		struct.belt = entity.surface.create_entity{
			name = type,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			fast_replace = true,
			spill = false
		}
	else
		struct.belt = entity.surface.create_entity{
			name = type,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			fast_replace = true,
			spill = false
		}
	end
	struct.active = type ~= "loader-conveyor"
	struct.inserter_left.active = struct.active and not struct.suppressed
	struct.inserter_right.active = struct.active and not struct.suppressed
end
local function snapBelt(belt,direction)
	-- check if a neighbour exists in the given direction, quick-replace me if so and return either the existing or newly replaced belt
	-- can assume just one neighbour since these are managed entities
	local neighbour = belt.belt_neighbours[direction][1]
	if not neighbour then return belt end
	if string.starts_with(neighbour.name,"loader-") then return belt end
	if #neighbour.belt_neighbours.inputs > 1 then return belt end -- disallow side-loading
	return belt.surface.create_entity{
		name = "loader-"..neighbour.name,
		position = belt.position,
		direction = belt.direction,
		force = belt.force,
		fast_replace = true,
		spill = false
	}
end

local function addInput(entity, offset, target, direction)
	if not script_data[entity.unit_number] then script_data[entity.unit_number] = {} end

	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	local position = math2d.position.add(entity.position, offset)
	direction = direction or defines.direction.north
	local belt = entity.surface.create_entity{
		name = "loader-conveyor",
		position = position,
		direction = (entity.direction + direction) % 8,
		force = entity.force,
		raise_built = true
	}
	belt = snapBelt(belt,"inputs")
	local isactive = belt.name ~= "loader-conveyor"
	local inserter_left = entity.surface.create_entity{
		name = "loader-inserter",
		position = entity.position,
		direction = (entity.direction + direction) % 8,
		force = entity.force,
		raise_built = true
	}
	inserter_left.pickup_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,0.25},((entity.direction+direction)%8)/8*360))
	inserter_left.drop_position = (target or entity).position
	inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
	inserter_left.operable = false
	inserter_left.minable = false
	inserter_left.destructible = false
	inserter_left.active = isactive
	local inserter_right = entity.surface.create_entity{
		name = "loader-inserter",
		position = entity.position,
		direction = (entity.direction + direction) % 8,
		force = entity.force,
		raise_built = true
	}
	inserter_right.pickup_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,0.25},((entity.direction+direction)%8)/8*360))
	inserter_right.drop_position = (target or entity).position
	inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
	inserter_right.operable = false
	inserter_right.minable = false
	inserter_right.destructible = false
	inserter_right.active = isactive
	local visual = rendering.draw_sprite{
		sprite = "utility.indication_line",
		orientation = ((entity.direction + direction) % 8)/8,
		render_layer = "arrow",
		target = entity,
		target_offset = {offset.x, offset.y},
		surface = entity.surface,
		only_in_alt_mode = true
	}
	script_data[entity.unit_number][offset.x..","..offset.y] = {
		belt = belt,
		inserter_left = inserter_left,
		inserter_right = inserter_right,
		active = isactive,
		suppressed = false,
		visual = visual
	}
	return belt, inserter_left, inserter_right, visual
end

local function addOutput(entity, offset, target, direction)
	if not script_data[entity.unit_number] then script_data[entity.unit_number] = {} end

	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	local position = math2d.position.add(entity.position, offset)
	direction = direction or defines.direction.north
	local belt = entity.surface.create_entity{
		name = "loader-conveyor",
		position = position,
		direction = (entity.direction+direction)%8,
		force = entity.force,
		raise_built = true
	}
	belt = snapBelt(belt,"outputs")
	local isactive = belt.name ~= "loader-conveyor"
	local inserter_left = entity.surface.create_entity{
		name = "loader-inserter",
		position = entity.position,
		direction = (entity.direction+direction)%8,
		force = entity.force,
		raise_built = true
	}
	inserter_left.pickup_position = (target or entity).position
	inserter_left.drop_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,-0.49},((entity.direction+direction)%8)/8*360))
	inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
	inserter_left.operable = false
	inserter_left.minable = false
	inserter_left.destructible = false
	inserter_left.active = isactive
	local inserter_right = entity.surface.create_entity{
		name = "loader-inserter",
		position = entity.position,
		direction = (entity.direction+direction)%8,
		force = entity.force,
		raise_built = true
	}
	inserter_right.pickup_position = (target or entity).position
	inserter_right.drop_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,-0.49},((entity.direction+direction)%8)/8*360))
	inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
	inserter_right.operable = false
	inserter_right.minable = false
	inserter_right.destructible = false
	inserter_right.active = isactive
	local visual = rendering.draw_sprite{
		sprite = "utility.indication_arrow",
		orientation = ((entity.direction+direction)%8)/8,
		render_layer = "arrow",
		target = entity,
		target_offset = {offset.x, offset.y},
		surface = entity.surface,
		only_in_alt_mode = true
	}

	script_data[entity.unit_number][offset.x..","..offset.y] = {
		belt = belt,
		inserter_left = inserter_left,
		inserter_right = inserter_right,
		active = isactive,
		suppressed = false,
		visual = visual
	}
	return belt, inserter_left, inserter_right, visual
end

local function remove(entity, event)
	-- assume it exists - it not existing is an error condition
	local structs = script_data[entity.unit_number]
	for _,struct in pairs(structs) do
		-- any items held in the inserters or remaining on the belt are added to event.buffer, if it exists, or spilled if not
		local belt = struct.belt
		addToBufferOrSpillTransportBelt(belt, event.buffer or nil)
		belt.destroy()

		local inserter = struct.inserter_left
		if inserter.held_stack and inserter.held_stack.valid_for_read then
			addToBufferOrSpillStack(inserter.held_stack, entity, event.buffer or nil)
		end
		inserter.destroy()

		inserter = struct.inserter_right
		if inserter.held_stack and inserter.held_stack.valid_for_read then
			addToBufferOrSpillStack(inserter.held_stack, entity, event.buffer or nil)
		end
		inserter.destroy()

		-- visualisation is linked to the main entity so it gets destroyed automatically
	end
	script_data[entity.unit_number] = nil
end

local function toggle(entity, offset, enable)
	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	-- assume it exists - it not existing is an error condition
	local struct = script_data[entity.unit_number][offset.x..","..offset.y]
	struct.suppressed = not enable
	struct.inserter_left.active = enable and struct.active
	struct.inserter_right.active = enable and struct.active
end
local function isEnabled(entity, offset)
	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	-- assume it exists - it not existing is an error condition
	local struct = script_data[entity.unit_number][offset.x..","..offset.y]
	return not struct.suppressed
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.type ~= "transport-belt" and entity.type ~= "underground-belt" then return end
	if entity.name == "loader-conveyor" then return end
	for side,belts in pairs(entity.belt_neighbours) do
		for _,belt in pairs(belts) do
			if string.starts_with(belt.name,"loader-") then
				if belt.name ~= "loader-"..entity.name then
					replaceBelt(belt, "loader-"..entity.name)
				end
			end
		end
	end
end
local function onRotated(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.type ~= "transport-belt" and entity.type ~= "underground-belt" then return end
	-- rotation may create new links, but won't affect old links
	-- at worst, it disconnects them if the belts are now facing each other - in which case they become each others' output, I think! (check this)
	for side,belts in pairs(entity.belt_neighbours) do
		for _,belt in pairs(belts) do
			if string.starts_with(belt.name,"loader-") then
				if belt.name ~= "loader-"..entity.name then
					replaceBelt(belt, "loader-"..entity.name)
				end
			end
		end
	end
end
local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.type ~= "transport-belt" and entity.type ~= "underground-belt" then return end
	-- disconnect neighbouring loaders
	for side,belts in pairs(entity.belt_neighbours) do
		for _,belt in pairs(belts) do
			if string.starts_with(belt.name,"loader-") then
				if belt.name ~= "loader-conveyor" then
					replaceBelt(belt, "loader-conveyor", event.buffer or nil)
				end
			end
		end
	end
end

return {
	addInput = addInput,
	addOutput = addOutput,
	toggle = toggle,
	isEnabled = isEnabled,
	remove = remove,
	on_init = function()
		global.io = global.io or script_data
	end,
	on_load = function()
		script_data = global.io or script_data
	end,
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_player_rotated_entity] = onRotated
	}
}
