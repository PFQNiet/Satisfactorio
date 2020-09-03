local hub = "the-hub"
local terminal = "the-hub-terminal"
local bench = "craft-bench"

local function retrieveItemsFromCraftBench(bench, target)
	-- collect items from a given assembler's inventories (input, output, modules, and craft-in-progress if any) and place them in target
	-- note this is best used with an event buffer, as it makes no checks for whether it was actually able to insert the items.
	local inventories = {
		defines.inventory.assembling_machine_input,
		defines.inventory.assembling_machine_output,
		defines.inventory.assembling_machine_modules
	}
	for _, k in ipairs(inventories) do
		local source = bench.get_inventory(k)
		for i = 1, #source do
			local stack = source[i]
			if stack.valid and stack.valid_for_read then
				target.insert(stack)
			end
		end
	end
	if bench.is_crafting() then
		-- a craft was left in progress, get the ingredients and give those back too
		local recipe = bench.get_recipe()
		for i = 1, #recipe.ingredients do
			target.insert(recipe.ingredients[i])
		end
	end
end

local dirnames = {
	[defines.direction.north] = hub.."-north",
	[defines.direction.east] = hub.."-east",
	[defines.direction.south] = hub.."-south",
	[defines.direction.west] = hub.."-west"
}
local rotations = {
	[defines.direction.north] = {0,-1},
	[defines.direction.east] = {1,0},
	[defines.direction.south] = {0,1},
	[defines.direction.west] = {-1,0}
}
local function position(relative,to)
	local rot1 = rotations[to.direction]
	local rot2 = rotations[(to.direction+2)%8]
	local rel = {relative[1] or relative.x or 0, relative[2] or relative.y or 0}
	local pos = {to.position[1] or to.position.x or 0, to.position[2] or to.position.y or 0}
	return {
		pos[1] + rel[1]*rot1[1] + rel[2]*rot2[1],
		pos[2] + rel[1]*rot1[2] + rel[2]*rot2[2]
	}
end
local bench_pos = {0,2.5}
local bench_rotation = 2 -- 90deg

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == hub then
		-- floor graphic
		entity.surface.create_entity{
			name = dirnames[entity.direction],
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		-- terminal
		entity.surface.create_entity{
			name = terminal,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		-- craft bench
		local craft = entity.surface.create_entity{
			name = bench,
			position = position(bench_pos,entity),
			direction = (entity.direction+bench_rotation)%8,
			force = entity.force,
			raise_built = true
		}
		craft.minable = false
		-- remove base item
		entity.destroy()
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == terminal then
		-- find the craft bench that should be right here
		local craft = entity.surface.find_entity(bench,position(bench_pos,entity))
		if not craft or not craft.valid then
			game.print("Couldn't find the craft bench")
			return
		end
		if event.buffer then
			retrieveItemsFromCraftBench(craft, event.buffer)
		end
		craft.destroy()
		-- and the graphic
		local dec = entity.surface.find_entity(dirnames[entity.direction],entity.position)
		if not dec or not dec.valid then
			game.print("Couldn't find the graphic")
			return
		end
		dec.destroy()
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
