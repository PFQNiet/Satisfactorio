-- uses global.io to track structures based on [surface, y, x] > {belt, inserter1, inserter2, indicator}
local math2d = require("math2d")

local function addToBufferOrSpillStack(stack, entity, buffer)
	if buffer then
		buffer.insert(stack)
	else
		entity.surface.spill_item_stack(entity.position, stack, true, entity.force, false)
	end
end

local function addInput(entity, offset, target, direction)
	if not global['io'] then global['io'] = {} end
	if not global['io'][entity.surface.index] then global['io'][entity.surface.index] = {} end
	if not global['io'][entity.surface.index][entity.position.y] then global['io'][entity.surface.index][entity.position.y] = {} end
	if not global['io'][entity.surface.index][entity.position.y][entity.position.x] then global['io'][entity.surface.index][entity.position.y][entity.position.x] = {} end

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
	local visual = rendering.draw_sprite{
		sprite = "utility.indication_line",
		orientation = ((entity.direction + direction) % 8)/8,
		render_layer = "arrow",
		target = entity,
		target_offset = {offset.x, offset.y},
		surface = entity.surface,
		only_in_alt_mode = true
	}
	global['io'][entity.surface.index][entity.position.y][entity.position.x][offset.x..","..offset.y] = {
		belt = belt,
		inserter_left = inserter_left,
		inserter_right = inserter_right,
		visual = visual
	}
	return belt, inserter_left, inserter_right, visual
end

local function addOutput(entity, offset, target, direction)
	if not global['io'] then global['io'] = {} end
	if not global['io'][entity.surface.index] then global['io'][entity.surface.index] = {} end
	if not global['io'][entity.surface.index][entity.position.y] then global['io'][entity.surface.index][entity.position.y] = {} end
	if not global['io'][entity.surface.index][entity.position.y][entity.position.x] then global['io'][entity.surface.index][entity.position.y][entity.position.x] = {} end

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
	local visual = rendering.draw_sprite{
		sprite = "utility.indication_arrow",
		orientation = ((entity.direction+direction)%8)/8,
		render_layer = "arrow",
		target = entity,
		target_offset = {offset.x, offset.y},
		surface = entity.surface,
		only_in_alt_mode = true
	}

	global['io'][entity.surface.index][entity.position.y][entity.position.x][offset.x..","..offset.y] = {
		belt = belt,
		inserter_left = inserter_left,
		inserter_right = inserter_right,
		visual = visual
	}
	return belt, inserter_left, inserter_right, visual
end

local function remove(entity, event)
	-- assume it exists - it not existing is an error condition
	local structs = global['io'][entity.surface.index][entity.position.y][entity.position.x]
	for _,struct in pairs(structs) do
		-- any items held in the inserters or remaining on the belt are added to event.buffer, if it exists, or spilled if not
		local belt = struct.belt
		if belt and belt.valid then
			for i = 1,belt.get_max_transport_line_index() do
				local line = belt.get_transport_line(i)
				local items = line.get_contents()
				for name,count in pairs(items) do
					addToBufferOrSpillStack({name=name,count=count}, entity, event.buffer or nil)
				end
			end
			belt.destroy()
		else
			game.print("Could not find the loader belt")
		end

		local inserter = struct.inserter_left
		if inserter and inserter.valid then
			if inserter.held_stack and inserter.held_stack.valid_for_read then
				addToBufferOrSpillStack(inserter.held_stack, entity, event.buffer or nil)
			end
			inserter.destroy()
		else
			game.print("Could not find left loader inserter")
		end

		inserter = struct.inserter_right
		if inserter and inserter.valid then
			if inserter.held_stack and inserter.held_stack.valid_for_read then
				addToBufferOrSpillStack(inserter.held_stack, entity, event.buffer or nil)
			end
			inserter.destroy()
		else
			game.print("Could not find right loader inserter")
		end

		-- visualisation is linked to the main entity so it gets destroyed automatically
	end
	global['io'][entity.surface.index][entity.position.y][entity.position.x] = nil
end

local function toggle(entity, offset, enable)
	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	-- assume it exists - it not existing is an error condition
	local struct = global['io'][entity.surface.index][entity.position.y][entity.position.x][offset.x..","..offset.y]
	struct.inserter_left.active = enable
	struct.inserter_right.active = enable
end
local function isEnabled(entity, offset)
	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	-- assume it exists - it not existing is an error condition
	local struct = global['io'][entity.surface.index][entity.position.y][entity.position.x][offset.x..","..offset.y]
	return struct.inserter_left.active
end

return {
	addInput = addInput,
	addOutput = addOutput,
	toggle = toggle,
	isEnabled = isEnabled,
	remove = remove
}
