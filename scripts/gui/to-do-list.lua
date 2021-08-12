-- TODO Handle prototypes changing by re-evaluating ingredient requirements

---@class ToDoListGui
---@field player LuaPlayer
---@field items table<string, ToDoListGuiRecipe>
---@field ingredients table<string, ToDoListGuiIngredient>
---@field components ToDoListGuiComponents
---@field editor ToDoListGuiAmountEditorComponents

---@class ToDoListGuiComponents
---@field frame LuaGuiElement
---@field toggle LuaGuiElement
---@field close LuaGuiElement
---@field items LuaGuiElement
---@field ingredients LuaGuiElement

---@class ToDoListGuiAmountEditorComponents
---@field mask LuaGuiElement
---@field editing ToDoListGuiRecipe
---@field editor LuaGuiElement
---@field edit_count LuaGuiElement
---@field edit_confirm LuaGuiElement
---@field edit_delete LuaGuiElement

---@class ToDoListGuiRecipe
---@field name string
---@field recipe LuaRecipePrototype
---@field button LuaGuiElement
---@field wanted number Total number of the product wanted, rounded up to the next whole number of recipe crafts
---@field ingredients table<string, ToDoListGuiIngredient> Map ingredient type/name to corresponding entry

---@class ToDoListGuiIngredient
---@field key string Own index in ingredient list
---@field type '"item"'|'"fluid"'
---@field name string
---@field localised_name LocalisedString
---@field item string For fluids, this is the packaged version of that fluid
---@field target number Amount needed to craft everything in the list
---@field required_by table<string,boolean> Map of recipe names that use this ingredient; if empty, the item should be removed
---@field flow LuaGuiElement
---@field count LuaGuiElement
---@field bar LuaGuiElement

---@class ToDoListIngredientData
---@field type string
---@field name string
---@field localised_name LocalisedString
---@field amount number

---@alias global.gui.todo_list table<uint, ToDoListGui>
---@type global.gui.todo_list
local script_data = {}

-- Map fluid names to packaged-fluid item names along with compression ratio (number of fluid per package)
---@type table<string,table>
local packaged_fluids = {
	["water"] = {"packaged-water",1},
	["crude-oil"] = {"packaged-oil",1},
	["heavy-oil"] = {"packaged-heavy-oil-residue",1},
	["alumina-solution"] = {"packaged-alumina-solution",1},
	["sulfuric-acid"] = {"packaged-sulfuric-acid",1},
	["fuel"] = {"packaged-fuel",1},
	["liquid-biofuel"] = {"packaged-liquid-biofuel",1},
	["turbofuel"] = {"packaged-turbofuel",1},
	["nitrogen-gas"] = {"packaged-nitrogen-gas",4},
	["nitric-acid"] = {"packaged-nitric-acid",1},
}

---@param player LuaPlayer
---@param frame LuaGuiElement
local function setFramePosition(player, frame)
	frame.location = {
		player.display_resolution.width-512*player.display_scale,
		40*player.display_scale
	}
end

---@param player LuaPlayer
---@return ToDoListGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return ToDoListGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen

	local frame = gui.add{
		type = "frame",
		name = "to-do-list",
		direction = "vertical",
		style = "inner_frame_in_outer_frame"
	}
	frame.visible = false
	local title_flow = frame.add{type = "flow"}
	local toggle = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/collapse"}
	local title = title_flow.add{type = "label", caption = {"gui.to-do-title"}, style = "frame_title"}
	title.drag_target = frame
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = frame
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white"}

	local content = frame.add{
		type = "frame",
		style = "inside_shallow_frame",
		direction = "vertical",
		name = "content"
	}
	local wanted = content.add{
		type = "frame",
		style = "todolist_recipe_frame",
		name = "wanted"
	}
	local wanted_list = wanted.add{
		type = "table",
		style = "filter_slot_table",
		column_count = 5,
		name = "to-do-list-wanted"
	}
	local ingredient_list = content.add{
		type = "scroll-pane",
		name = "list",
		style = "todolist_scroll_pane",
		horizontal_scroll_policy = "never",
		vertical_scroll_policy = "always"
	}
	setFramePosition(player, frame)

	script_data[player.index] = {
		player = player,
		items = {},
		ingredients = {},
		components = {
			frame = frame,
			toggle = toggle,
			close = close,
			items = wanted_list,
			ingredients = ingredient_list
		},
		editor = {
			mask = nil,
			editor = nil,
			editing = nil,
			edit_count = nil,
			edit_confirm = nil,
			edit_delete = nil
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
local function openGui(player)
	local data = getGui(player)
	if not data then data = createGui(player) end
	data.components.frame.visible = true
end

---@param player LuaPlayer
local function closeGui(player)
	local data = getGui(player)
	if not data then return end
	if player.opened == data.components.frame then
		player.opened = nil
	end
	local components = data.components
	components.frame.visible = false
	components.items.clear()
	components.ingredients.clear()
	data.items = {}
	data.ingredients = {}
end

---@param player LuaPlayer
local function toggleGuiVisibility(player)
	local data = getGui(player)
	if not data then return end
	local components = data.components
	local elem = components.ingredients
	if elem.visible then
		elem.visible = false
		components.toggle.sprite = "utility/expand"
	else
		elem.visible = true
		components.toggle.sprite = "utility/collapse"
	end
end

---@param player LuaPlayer
---@param ingredient Ingredient
---@return ToDoListGuiIngredient
local function createIngredient(player, ingredient)
	local data = getGui(player)
	local materials = data.ingredients
	local list = data.components.ingredients
	local key = ingredient.type.."/"..ingredient.name
	---@type LuaItemPrototype|LuaFluidPrototype
	local proto = game[ingredient.type.."_prototypes"][ingredient.name]
	local order = proto.group.order.."-"..proto.subgroup.order.."-"..proto.order

	-- iterate through existing ingredients to find where to slot this ingredient
	local index = 1
	for i=1,#list.children do
		local compare = list.children[i].tags['order']
		if compare < order then
			index = index + 1
		else
			break
		end
	end

	local flow = list.add{
		type = "flow",
		direction = "horizontal",
		style = "todolist_ingredient_flow",
		index = index,
		tags = {
			order = order
		}
	}
	local left = flow.add{
		type = "flow",
		direction = "vertical"
	}
	local top = left.add{
		type = "flow",
		direction = "horizontal"
	}
	top.add{
		type = "label",
		caption = proto.localised_name,
		style = "todolist_ingredient_label"
	}
	top.add{type="empty-widget", style="filler_widget"}
	local count = top.add{
		type = "label",
		caption = {"gui.fraction","0","0"}
	}
	local bar = left.add{
		type = "progressbar",
		style = "stretched_progressbar",
		value = 0,
		tags = {
			fraction = {0,0}
		}
	}

	flow.add{
		type = "sprite-button",
		style = "transparent_slot",
		sprite = ingredient.type.."/"..ingredient.name,
		tooltip = proto.localised_name
	}

	materials[key] = {
		key = key,
		type = ingredient.type,
		name = ingredient.name,
		localised_name = proto.localised_name,
		item = ingredient.type == "item" and ingredient.name or packaged_fluids[ingredient.name][1],
		target = 0,
		required_by = {},
		flow = flow,
		count = count,
		bar = bar
	}
	return materials[key]
end

-- Called when an item is removed and no other items have the ingredient as a requirement
---@param player LuaPlayer
---@param ingredient ToDoListGuiIngredient
local function removeIngredient(player, ingredient)
	local data = getGui(player)
	if not data then return end
	assert(not next(ingredient.required_by), "Ingredient "..ingredient.key.." is still being used by "..serpent.line(ingredient.required_by))
	local materials = data.ingredients
	ingredient.flow.destroy()
	materials[ingredient.key] = nil
end

---@param player LuaPlayer
---@param ingredient ToDoListGuiIngredient
---@param delta int
local function incrementIngredient(player, ingredient, delta)
	local data = getGui(player)
	ingredient.target = ingredient.target + delta

	local bar = ingredient.bar
	local fraction = bar.tags['fraction']
	fraction[2] = ingredient.target
	bar.tags = {fraction = fraction}

	ingredient.count.caption = {"gui.fraction", util.format_number(fraction[1]), util.format_number(fraction[2])}
	bar.value = fraction[1] / fraction[2]
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype
---@return boolean
local function isItemInList(player, recipe)
	local data = getGui(player)
	if not data then return false end
	if not data.items[recipe.name] then return false end
	return true
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype
---@return ToDoListGuiRecipe
local function createItem(player, recipe)
	local data = getGui(player)
	local list = data.components.items
	local items = data.items
	local order = recipe.group.order.."-"..recipe.subgroup.order.."-"..recipe.order

	-- iterate through existing recipes to find where to slot this recipe
	local index = 1
	for i=1,#list.children do
		local compare = list.children[i].tags['order']
		if compare < order then
			index = index + 1
		else
			break
		end
	end

	local button = list.add{
		type = "sprite-button",
		style = "slot_button",
		sprite = "recipe/"..recipe.name,
		tooltip = recipe.localised_name,
		number = 0,
		index = index,
		tags = {
			name = recipe.name,
			order = order
		}
	}
	local ingredients = {}
	for _,ingredient in pairs(recipe.ingredients) do
		local key = ingredient.type.."/"..ingredient.name
		local entry = data.ingredients[key]
		if not entry then entry = createIngredient(player, ingredient) end
		entry.required_by[recipe.name] = true
		ingredients[key] = entry
	end
	items[recipe.name] = {
		name = recipe.name,
		recipe = recipe,
		button = button,
		wanted = 0,
		ingredients = ingredients
	}
	return items[recipe.name]
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype
local function removeItem(player, recipe)
	local data = getGui(player)
	if not data then return end
	local items = data.items
	local item = items[recipe.name]
	if not item then return end
	item.button.destroy()
	for _,ingredient in pairs(recipe.ingredients) do
		local entry = item.ingredients[ingredient.type.."/"..ingredient.name]
		entry.required_by[recipe.name] = nil
		if not next(entry.required_by) then
			removeIngredient(player, entry)
		else
			incrementIngredient(player, entry, -item.wanted / recipe.main_product.amount * ingredient.amount)
		end
	end
	items[recipe.name] = nil
	if not next(items) then
		closeGui(player)
	end
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype
---@param count uint
local function setItem(player, recipe, count)
	if count > 0 then
		assert(count % recipe.main_product.amount == 0, "Item count is expected to be a multiple of the recipe yield. "..count.." does not divide by "..recipe.main_product.amount)
		local data = getGui(player)
		local items = data.items
		local item = items[recipe.name]
		if not item then item = createItem(player, recipe) end
		-- how many multiples of the recipe have been added (or removed, if negative)
		-- this should always be an integer due to the assertion above
		local difference = (count - item.wanted) / recipe.main_product.amount
		item.wanted = count
		item.button.number = count
		for _,ingredient in pairs(recipe.ingredients) do
			local key = ingredient.type.."/"..ingredient.name
			local entry = data.ingredients[key]
			-- note ingredients will never hit zero in this circumstance
			incrementIngredient(player, entry, difference * ingredient.amount)
		end
	else
		removeItem(player, recipe)
	end
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype
---@param count uint
local function incrementItem(player, recipe, count)
	local data = getGui(player)
	if not data then data = createGui(player) end
	local existing = data.items[recipe.name]
	if existing then count = count + existing.wanted end
	setItem(player, recipe, count)
	if next(data.items) then
		openGui(player)
	end
end

---@param player LuaPlayer
local function updateInventory(player)
	local data = getGui(player)
	if not data then return end
	local list = data.ingredients
	local inventory = player.get_main_inventory().get_contents()

	local cursor = player.cursor_stack
	if cursor.valid_for_read then
		inventory[cursor.name] = (inventory[cursor.name] or 0) + cursor.count
	end

	-- "handcrafting" building input inventories count too!
	if player.opened_gui_type == defines.gui_type.entity and (player.opened.name == "craft-bench" or player.opened.name == "equipment-workshop") then
		for _,key in pairs{defines.inventory.assembling_machine_input, defines.inventory.assembling_machine_output} do
			local merge = player.opened.get_inventory(key).get_contents()
			for k,v in pairs(merge) do
				inventory[k] = (inventory[k] or 0) + v
			end
		end
		if player.opened.is_crafting() then
			local ingredients = player.opened.get_recipe().prototype.ingredients
			for _,i in pairs(ingredients) do
				inventory[i.name] = (inventory[i.name] or 0) + i.amount
			end
		end
	end

	for _,entry in pairs(list) do
		local compress = packaged_fluids[entry.name] and packaged_fluids[entry.name][2] or 1
		local owned = (inventory[entry.item] or 0) * compress
		entry.count.caption = {"gui.fraction", util.format_number(owned), util.format_number(entry.target)}
		entry.bar.value = owned / entry.target
		entry.bar.tags = {fraction = {owned,entry.target}}
	end
end

---@param player LuaPlayer
---@param source LuaGuiElement
local function editItemRequestCount(player,source)
	local data = getGui(player)

	source.style = "yellow_slot_button"
	local index = source.get_index_in_parent()
	local name = source.tags['name']

	local entry = data.items[name]
	assert(entry.button == source)
	local editor = data.editor
	editor.editing = entry

	local mask = editor.mask
	if not mask then
		mask = player.gui.screen.add{
			type = "frame",
			style = "invisible_frame"
		}
		editor.mask = mask
	else
		mask.visible = true
		mask.bring_to_front()
	end
	mask.style.width = player.display_resolution.width / player.display_scale
	mask.style.height = player.display_resolution.height / player.display_scale
	mask.location = {0,0}

	local gui = editor.editor
	if not gui then
		gui = player.gui.screen.add{
			type = "frame",
			style = "frame_with_even_paddings"
		}
		editor.editor = gui

		local flow = gui.add{
			type = "flow",
			direction = "horizontal",
			style = "vertically_aligned_flow"
		}

		editor.edit_count = flow.add{
			type = "textfield",
			numeric = true,
			allow_decimal = false,
			allow_negative = false,
			lose_focus_on_confirm = true,
			style = "short_number_textfield"
		}
		editor.edit_confirm = flow.add{
			type = "sprite-button",
			style = "tool_button_green",
			tooltip = {"gui.confirm"},
			sprite = "utility/check_mark_white"
		}
		editor.edit_delete = flow.add{
			type = "sprite-button",
			style = "tool_button_red",
			tooltip = {"gui.delete"},
			sprite = "utility/trash"
		}
	else
		gui.visible = true
		gui.bring_to_front()
	end
	editor.edit_count.text = tostring(entry.wanted)

	local loc = data.components.frame.location
	gui.location = {
		loc.x + 24 + ((index-1)%5)/4*32,
		loc.y + 92 + math.floor((index-1)/5)*40
	}
end

---@param player LuaPlayer
local function closeItemRequestCount(player)
	local data = getGui(player)
	local editor = data.editor
	editor.editing.button.style = "slot_button"
	editor.mask.visible = false
	editor.editor.visible = false
end

---@param player LuaPlayer
local function updateItemRequestCount(player)
	local data = getGui(player)
	local editor = data.editor
	local entry = editor.editing
	local wanted = tonumber(editor.edit_count.text)
	local yield = editor.editing.recipe.main_product.amount
	wanted = math.ceil(wanted / yield) * yield
	closeItemRequestCount(player)
	setItem(player, entry.recipe, wanted)
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components
	local editor = data.editor

	if event.element == components.toggle then
		toggleGuiVisibility(player)

	elseif event.element == components.close then
		closeGui(player)

	elseif event.element.parent == components.items then
		editItemRequestCount(player, event.element)

	elseif event.element == editor.edit_confirm then
		updateItemRequestCount(player)

	elseif event.element == editor.edit_delete then
		editor.edit_count.text = "0"
		updateItemRequestCount(player)

	elseif event.element == editor.mask then
		closeItemRequestCount(player)

	end
end

---@param event on_gui_confirmed
local function onGuiConfirmed(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end

	if event.element == data.editor.edit_count then
		updateItemRequestCount(player)
	end
end

---@param event on_gui_opened|on_gui_closed
local function onGuiToggle(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.name == "craft-bench" or event.entity.name == "equipment-workshop" then
		updateInventory(game.players[event.player_index])
	end
end

local function onResolutionChanged(event)
	local player = game.players[event.player_index]
	local data = getGui(player)
	if data then
		setFramePosition(player, data.components.frame)
	end
end

return {
	add_item = incrementItem,
	is_in_list = isItemInList,
	update_inventory = updateInventory,
	lib = {
		on_init = function()
			global.gui.todo_list = global.gui.todo_list or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.todo_list or script_data
		end,
		events = {
			[defines.events.on_gui_opened] = onGuiToggle,
			[defines.events.on_gui_closed] = onGuiToggle,
			[defines.events.on_gui_click] = onGuiClick,
			[defines.events.on_gui_confirmed] = onGuiConfirmed,
			[defines.events.on_player_display_resolution_changed] = onResolutionChanged,
			[defines.events.on_player_display_scale_changed] = onResolutionChanged
		}
	}
}
