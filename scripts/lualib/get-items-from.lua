---@param entity LuaEntity Where the item came from
---@param stack LuaItemStack
---@param target LuaInventory|nil
local function retrieveItemStack(entity, stack, target)
	if not stack.valid_for_read then return end
	if stack.prototype.has_flag("only-in-cursor") then return end
	if target then
		local inserted = target.insert(stack)
		if inserted == stack.count then return end
		stack.count = stack.count - inserted
	end
	-- no buffer provided, or the buffer overflowed
	entity.surface.spill_item_stack(entity.position, stack, true, entity.force, false)
end

---@param entity LuaEntity
---@param inventory LuaInventory
---@param target LuaInventory|nil
local function retrieveItemsFromInventory(entity, inventory, target)
	if not (inventory and inventory.valid) then return end
	for i=1,#inventory do
		retrieveItemStack(entity, inventory[i], target)
	end
end

--- collect held item from inserter
---@param inserter LuaEntity
---@param target LuaInventory|nil
local function retrieveItemFromInserter(inserter, target)
	retrieveItemStack(inserter, inserter.held_stack, target)
end

--- collect items from the Assembler inventories (input, output, modules, and craft-in-progress if any) and place them in target event buffer
---@param entity LuaEntity
---@param target LuaInventory|nil
local function retrieveItemsFromAssembler(entity, target)
	local inventories = {
		defines.inventory.assembling_machine_input,
		defines.inventory.assembling_machine_output,
		defines.inventory.assembling_machine_modules,
		defines.inventory.fuel
	}
	for _, k in pairs(inventories) do
		retrieveItemsFromInventory(entity, entity.get_inventory(k), target)
	end
	if entity.is_crafting() then
		-- a craft was left in progress, get the ingredients and give those back too
		local recipe = entity.get_recipe()
		for i = 1, #recipe.ingredients do
			local entry = recipe.ingredients[i]
			if entry.type == "item" then
				retrieveItemStack(entity, {name=entry.name, count=entry.amount}, target)
			end
		end
	end
end

--- collect items from Storage inventory and place them in target event buffer
---@param box LuaEntity
---@param target LuaInventory|nil
local function retrieveItemsFromStorage(box, target)
	local source = box.get_inventory(defines.inventory.chest)
	retrieveItemsFromInventory(box, source, target)
end

--- collect items from the fuel inventory and place them in target event buffer
---@param burner LuaEntity
---@param target LuaInventory|nil
local function retrieveItemsFromBurner(burner, target)
	local source = burner.get_inventory(defines.inventory.fuel)
	retrieveItemsFromInventory(burner, source, target)
end

--- collect items from the car's fuel and trunk and place them in the target event buffer
---@param car LuaEntity
---@param target LuaInventory|nil
local function retrieveItemsFromCar(car, target)
	retrieveItemsFromBurner(car, target) -- retrieve batteries
	local source = car.get_inventory(defines.inventory.car_trunk)
	retrieveItemsFromInventory(car, source, target)
end

--- collect items from the spider trunk and place them in target event buffer
---@param drone LuaEntity
---@param target LuaInventory|nil
local function retrieveItemsFromDrone(drone, target)
	retrieveItemsFromBurner(drone, target) -- retrieve batteries
	local source = drone.get_inventory(defines.inventory.spider_trunk)
	retrieveItemsFromInventory(drone, source, target)
end

return {
	inserter = retrieveItemFromInserter,
	assembler = retrieveItemsFromAssembler,
	storage = retrieveItemsFromStorage,
	burner = retrieveItemsFromBurner,
	car = retrieveItemsFromCar,
	spider = retrieveItemsFromDrone
}
