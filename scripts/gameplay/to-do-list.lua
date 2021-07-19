local bm = require(modpath.."scripts.lualib.building-management")
local string = require(modpath.."scripts.lualib.string")
local browser = require(modpath.."scripts.gui.recipe-browser")
local todo = require(modpath.."scripts.gui.to-do-list")

---@param product Product
---@param mode string
---@return uint
local function getYieldForProductAndMode(product, mode)
	local yield = product.amount
	if mode == "five" then yield = yield * 5 end
	if mode == "stack" then
		if product.type == "fluid" then
			yield = 100
		else
			yield = math.floor(game.item_prototypes[product.name].stack_size / yield) * yield
		end
	end
	return yield
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype
---@param mode string
browser.callbacks.add_todo = function(player, recipe, mode)
	local product = recipe.main_product
	local yield = getYieldForProductAndMode(product, mode)
	todo.add_item(player, recipe, yield)
	todo.update_inventory(player)
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype
---@param mode string
browser.callbacks.remove_todo = function(player, recipe, mode)
	local product = recipe.main_product
	local yield = getYieldForProductAndMode(product, mode)
	todo.add_item(player, recipe, -yield)
end

---@param event on_player_main_inventory_changed
local function onInventoryChanged(event)
	local player = game.players[event.player_index]
	todo.update_inventory(player)
end

-- when the player builds something, if it's in the to-do list, remove one
---@param event on_built_entity
local function onBuilt(event)
	local entity = event.created_entity
	if not (entity and entity.valid) then return end
	local recipe = bm.getBuildingRecipe(entity.name)
	if not recipe then return end
	local player = game.players[event.player_index]
	todo.add_item(player, recipe, -1)
end

-- when the player mines something, if it's in the to-do list, add one
---@param event on_player_mined_entity
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local recipe = bm.getBuildingRecipe(entity.name)
	if not recipe then return end
	local player = game.players[event.player_index]
	if not todo.is_in_list(player, recipe) then return end
	todo.add_item(player, recipe, 1)
end

-- when the player crafts something in the Craft Bench or Equipment Workshop, an event is raised
---@param event on_player_crafted_item
local function onCraft(event)
	local player = game.players[event.player_index]
	local recipe = event.recipe.prototype
	if string.ends_with(recipe.name, "-manual") then
		recipe = game.recipe_prototypes[string.remove_suffix(recipe.name, "-manual")]
		if not recipe then return end
		todo.add_item(player, recipe, -recipe.main_product.amount)
		todo.update_inventory(player)
	end
end

return {
	events = {
		[defines.events.on_player_main_inventory_changed] = onInventoryChanged,
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_player_crafted_item] = onCraft
	}
}
