return function(entity, target)
	-- collect items from a given assembler's inventories (input, output, modules, and craft-in-progress if any) and place them in target
	-- note this is best used with an event buffer, as it makes no checks for whether it was actually able to insert the items.
	-- TODO Check for failure to insert items and return the excess to be spilled
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
				target.insert(stack)
			end
		end
	end
	if entity.is_crafting() then
		-- a craft was left in progress, get the ingredients and give those back too
		local recipe = entity.get_recipe()
		for i = 1, #recipe.ingredients do
			target.insert(recipe.ingredients[i])
		end
	end
end
