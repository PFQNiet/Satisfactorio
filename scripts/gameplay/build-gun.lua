local bm = require(modpath.."scripts.lualib.building-management")
local gui = require(modpath.."scripts.gui.build-gun")

---Determine how many of the given recipe can be crafted
---@param player LuaPlayer
---@param recipe LuaRecipePrototype
---@param inventory LuaInventory
---@param buffer LuaInventory|nil An additional buffer, such as from a mining event, whose items should also be counted
---@return number
local function getAffordableCount(player, recipe, inventory, buffer)
	local recipe = player.force.recipes[recipe.name]
	if not recipe.enabled then return 0 end
	if player.cheat_mode then return 100 end
	local contents = inventory.get_contents()
	if buffer then
		for k,v in pairs(buffer.get_contents()) do
			contents[k] = (contents[k] or 0) + v
		end
	end
	local affordable = math.huge
	for _,ingredient in pairs(recipe.ingredients) do
		local got = contents[ingredient.name] or 0
		if got < ingredient.amount then
			return 0
		end
		affordable = math.min(affordable, math.floor(got / ingredient.amount))
	end
	return affordable
end

-- if the item to craft is a building, cancel the craft and put the item in the cursor
---@param event on_pre_player_crafted_item
local function onCraft(event)
	local recipe = bm.getBuildingRecipe(event.recipe.prototype.main_product.name)
	if recipe then
		local player = game.players[event.player_index]
		-- find the craft in the queue - it should really be the only one under Satisfactorio rules but to be safe...
		local index = 0
		for i=1,player.crafting_queue_size do
			if player.crafting_queue[i].recipe == event.recipe.name then
				index = i
				break
			end
		end
		if index == 0 then
			player.print("Can't find the item in the crafting queue...")
		else
			player.cancel_crafting{index=index,count=event.queued_count}
			if player.clear_cursor() then
				local item = event.recipe.prototype.products[1].name
				local affordable = getAffordableCount(player, recipe, player.get_main_inventory())
				player.cursor_stack.set_stack{name=item, count=math.min(affordable,game.item_prototypes[item].stack_size)}
				if player.opened_self then player.opened = nil end
			end
		end
	end
end

---@param event on_player_crafted_item
local function onCheatCraft(event)
	local recipe = bm.getBuildingRecipe(event.recipe.prototype.main_product.name)
	if recipe then
		local player = game.players[event.player_index]
		player.clear_cursor()
		event.item_stack.clear()
		local item = event.recipe.prototype.products[1].name
		player.cursor_stack.set_stack{name=item, count=game.item_prototypes[item].stack_size}
		if player.opened_self then player.opened = nil end
	end
end

---@param player LuaPlayer
---@return LuaRecipePrototype|nil
local function getRecipeFromCursor(player)
	local stack = player.cursor_stack.valid_for_read and player.cursor_stack or player.cursor_ghost
	if not stack then return end
	local name = stack.name
	local recipe = bm.getBuildingRecipe(name)
	if not (recipe and player.force.recipes[recipe.name].enabled) then return end
	return recipe
end

-- If the player has no item in hand but does have a ghost, they may have pipetted or selected an entity from their hotbar.
-- If the ghost item is a building, the building's recipe is enabled, and the player can afford it, swap the ghost for a real entity
-- * also called on main inventory change
-- * also called from onRemoved to update affordability and re-put a real entity if you mined stuff to afford what you're holding, so event.buffer may exist
---@param event on_player_cursor_stack_changed|on_player_main_inventory_changed|on_destroy
local function onCursorChange(event)
	local player = game.players[event.player_index]
	local recipe = getRecipeFromCursor(player)
	gui.update(player, recipe, event.buffer)

	if not recipe then return end

	local affordable = getAffordableCount(player, recipe, player.get_main_inventory(), event.buffer)
	if affordable < 1 then return end

	player.clear_cursor()
	local name = recipe.main_product.name
	player.cursor_stack.set_stack{name=name, count=math.min(affordable,game.item_prototypes[name].stack_size)}
end

---@param event on_build
local function onBuilt(event)
	local player = game.players[event.player_index]
	local entity = event.created_entity
	local name = entity.name
	-- if the item in the cursor is a building, check if the player has enough stuff (something else may have pulled items from the player's inventory)
	local recipe = bm.getBuildingRecipe(name)
	if not recipe then return end

	local inventory = player.get_main_inventory()
	local afford = getAffordableCount(player, recipe, inventory)
	local cost = entity.type == "curved-rail" and 4 or 1
	local source = recipe.main_product.name
	if afford < cost and player.controller_type ~= defines.controllers.editor then
		-- this shouldn't happen, but may if another player or script changes the player's inventory
		-- or maybe if building a curved rail with only 3 beams
		player.clear_cursor() -- cancel the build
		player.cursor_ghost = source
		player.create_local_flying_text{
			text = {"not-enough-ingredients"},
			create_at_cursor = true
		}
		player.play_sound{
			path = "utility/cannot_build"
		}
		entity.destroy()
		return
	end
	if not player.cheat_mode then
		-- items exist, now remove them
		for _,product in pairs(recipe.ingredients) do
			inventory.remove{name=product.name, count=product.amount*cost}
		end
		afford = afford-cost
	end
	-- in case the player runs out of materials, place a ghost in cursor instead
	if afford < 1 then
		player.cursor_ghost = source
	end
end

---@param event on_destroy
local function onRemoved(event)
	local player = event.player_index and game.players[event.player_index]
	local cheater = player and player.cheat_mode
	if event.buffer then
		for item,count in pairs(event.buffer.get_contents()) do
			-- if a building recipe exists for this item, replace it with the ingredients
			local recipe = bm.getBuildingRecipe(item)
			if recipe then
				event.buffer.remove{name=item, count=count}
				if not cheater then
					for _,product in pairs(recipe.ingredients) do
						-- building recipes are always solids
						event.buffer.insert{name=product.name, count=product.amount*count}
					end
				end
			end
		end
	end
	if player then onCursorChange(event) end
end

return {
	events = {
		[defines.events.on_pre_player_crafted_item] = onCraft,
		[defines.events.on_player_crafted_item] = onCheatCraft,
		[defines.events.on_player_cursor_stack_changed] = onCursorChange,
		[defines.events.on_player_main_inventory_changed] = onCursorChange,

		[defines.events.on_built_entity] = onBuilt, -- manual player build ONLY

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved
	}
}
