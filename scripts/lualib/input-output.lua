local math2d = require("math2d")

local function addToBufferOrSpillStack(stack, entity, buffer)
	if buffer then
		buffer.insert(stack)
	else
		entity.surface.spill_item_stack(entity.position, stack, true, entity.force, false)
	end
end

local function addOutput(entity, offset, direction)
	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	local position = math2d.position.add(entity.position, offset)
	direction = ((direction or defines.direction.north) + entity.direction) % 8
	local belt = entity.surface.create_entity{
		name = "loader-conveyor",
		position = position,
		direction = direction,
		force = entity.force,
		raise_built = true
	}
	local inserter_left = entity.surface.create_entity{
		name = "loader-inserter",
		position = position,
		direction = direction,
		force = entity.force,
		raise_built = true
	}
	inserter_left.pickup_position = entity.position
	inserter_left.drop_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,-0.49},direction/8*360))
	inserter_left.operable = false
	inserter_left.minable = false
	inserter_left.destructible = false
	local inserter_right = entity.surface.create_entity{
		name = "loader-inserter",
		position = position,
		direction = direction,
		force = entity.force,
		raise_built = true
	}
	inserter_right.pickup_position = entity.position
	inserter_right.drop_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,-0.49},direction/8*360))
	inserter_right.operable = false
	inserter_right.minable = false
	inserter_right.destructible = false
	local visual = rendering.draw_sprite{
		sprite = "utility.indication_arrow",
		orientation = direction/8,
		render_layer = "arrow",
		target = entity,
		target_offset = {offset.x, offset.y},
		surface = entity.surface,
		only_in_alt_mode = true
	}
	return belt, inserter_left, inserter_right, visual
end
local function removeOutput(entity, offset, event)
	offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
	local position = math2d.position.add(entity.position, offset)
	-- any items held in the inserters or remaining on the belt are added to event.buffer, if it exists, or spilled if not
	local belt = entity.surface.find_entity("loader-conveyor",position)
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
		game.print("Could not find the output belt")
	end
	for _=1,2 do
		-- both inserters behave the same so...
		local inserter = entity.surface.find_entity("loader-inserter",position)
		if inserter and inserter.valid then
			if inserter.held_stack and inserter.held_stack.valid_for_read then
				addToBufferOrSpillStack(inserter.held_stack, entity, event.buffer or nil)
			end
			inserter.destroy()
		else
			game.print("Could not find output inserter #".._)
		end
	end
	-- visualisation is linked to the main entity so it gets destroyed automatically
end

return {
	--addInput = addInput,
	addOutput = addOutput,
	-- removeInput = removeInput,
	removeOutput = removeOutput
}
