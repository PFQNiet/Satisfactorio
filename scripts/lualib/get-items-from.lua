local function retrieveItemsFromAssembler(entity, target)
	-- collect items from the Assembler inventories (input, output, modules, and craft-in-progress if any) and place them in target event buffer
	local inventories = {
		defines.inventory.assembling_machine_input,
		defines.inventory.assembling_machine_output,
		defines.inventory.assembling_machine_modules
	}
	for _, k in ipairs(inventories) do
		local source = entity.get_inventory(k)
		for i = 1, #source do
			local stack = source[i]
			if stack.valid and stack.valid_for_read then
				if target then
					target.insert(stack)
				else
					entity.surface.spill_item_stack(entity.position, stack, true, entity.force, false)
				end
			end
		end
	end
	if entity.is_crafting() then
		-- a craft was left in progress, get the ingredients and give those back too
		local recipe = entity.get_recipe()
		for i = 1, #recipe.ingredients do
			local entry = recipe.ingredients[i]
			if entry.type == "item" then
				local stack = {name=entry.name, count=entry.amount}
				if target then
					target.insert(stack)
				else
					entity.surface.spill_item_stack(entity.position, stack, true, entity.force, false)
				end
			end
		end
	end
end
local function retrieveItemsFromStorage(box, target)
	-- collect items from Storage inventory and place them in target event buffer
	local source = box.get_inventory(defines.inventory.chest)
	for i = 1, #source do
		local stack = source[i]
		if stack.valid and stack.valid_for_read then
			if target then
				target.insert(stack)
			else
				box.surface.spill_item_stack(box.position, stack, true, box.force, false)
			end
		end
	end
end
local function retrieveItemsFromBurner(burner, target)
	-- collect items from the fuel inventory and place them in target event buffer
	local source = burner.get_inventory(defines.inventory.fuel)
	for i = 1, #source do
		local stack = source[i]
		if stack.valid and stack.valid_for_read then
			if target then
				target.insert(stack)
			else
				burner.surface.spill_item_stack(burner.position, stack, true, burner.force, false)
			end
		end
	end
end
local function retrieveItemsFromDrone(drone, target)
	-- collect items from the spider trunk and place them in target event buffer
	local source = drone.get_inventory(defines.inventory.spider_trunk)
	for i = 1, #source do
		local stack = source[i]
		if stack.valid and stack.valid_for_read then
			if target then
				target.insert(stack)
			else
				drone.surface.spill_item_stack(drone.position, stack, true, drone.force, false)
			end
		end
	end
end

return {
	assembler = retrieveItemsFromAssembler,
	storage = retrieveItemsFromStorage,
	burner = retrieveItemsFromBurner,
	spider = retrieveItemsFromDrone
}
