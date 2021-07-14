---@class RecipeBrowserGui
---@field player LuaPlayer
---@field recipe LuaRecipePrototype
---@field components RecipeBrowserGuiComponents

---@class RecipeBrowserGuiComponents
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field select_item LuaGuiElement
---@field select_fluid LuaGuiElement
---@field heading LuaGuiElement
---@field content LuaGuiElement

---@alias global.gui.recipe_browser table<uint, RecipeBrowserGui>
---@type global.gui.recipe_browser
local script_data = {}

---@class RecipeBrowserGuiCallbacks
---@field search fun(player:LuaPlayer, search:Product)
---@field add_todo fun(player:LuaPlayer, recipe:LuaRecipePrototype, mode:string)
---@field remove_todo fun(player:LuaPlayer, recipe:LuaRecipePrototype, mode:string)
local callbacks = {
	search = function() end,
	add_todo = function() end,
	remove_todo = function() end
}

---@param player LuaPlayer
---@return RecipeBrowserGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return RecipeBrowserGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen

	local frame = gui.add{
		type = "frame",
		direction = "vertical",
		style = "inner_frame_in_outer_frame"
	}
	local title_flow = frame.add{type = "flow"}
	local title = title_flow.add{type = "label", caption = {"gui.recipe-browser-title"}, style = "frame_title"}
	title.drag_target = frame
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = frame
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white"}

	local container = frame.add{
		type = "frame",
		style = "inside_shallow_frame",
		direction = "vertical"
	}
	local heading = container.add{
		type = "frame",
		style = "full_subheader_frame",
		direction = "horizontal"
	}
	local select_item = heading.add{
		type = "choose-elem-button",
		elem_type = "item"
	}
	local select_fluid = heading.add{
		type = "choose-elem-button",
		elem_type = "fluid"
	}
	local subtitle = heading.add{
		type = "label",
		caption = {"gui.recipe-browser-select-item"},
		style = "heading_2_label"
	}

	local content = container.add{
		type = "scroll-pane",
		style = "recipe_browser_scroll_pane",
		horizontal_scroll_policy = "never",
		vertical_scroll_policy = "always"
	}

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			close = close,
			select_item = select_item,
			select_fluid = select_fluid,
			heading = subtitle,
			content = content
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@return RecipeBrowserGui
local function openGui(player)
	local data = getGui(player)
	if not data then data = createGui(player) end

	local frame = data.components.frame
	frame.visible = true
	player.opened = frame
	frame.force_auto_center()
	return data
end

---@param player LuaPlayer
local function closeGui(player)
	local data = getGui(player)
	if not data then return end
	if player.opened == data.components.frame then
		player.opened = nil
	end
	data.components.frame.visible = false
end

---@param player LuaPlayer
local function toggleGui(player)
	local data = getGui(player)
	if not data then return openGui(player) end
	if data.components.frame.visible then return closeGui(player) end
	return openGui(player)
end

---@param player LuaPlayer
---@param searched LuaItemPrototype|LuaFluidPrototype
---@param techs LuaTechnologyPrototype[]
local function showTechsToUnlock(player, searched, techs)
	local data = getGui(player)
	local content = data.components.content

	content.clear()
	local nomatch = content.add{
		type = "label",
		style = "heading_2_label",
		caption = {"gui.recipe-browser-no-recipe",searched.localised_name}
	}
	if #techs == 0 then
		nomatch.caption = {"gui.recipe-browser-no-technology-either",searched.localised_name}
		content.add{
			type = "label",
			caption = {"gui.recipe-browser-maybe-in-wild"}
		}
	else
		local techlist = content.add{
			type = "flow",
			direction = "vertical"
		}
		techlist.add{
			type = "label",
			style = "caption_label",
			caption = {"gui.recipe-browser-tech-unlock",#techs}
		}
		for _,tech in ipairs(techs) do
			local entry = techlist.add{
				type = "flow",
				direction = "horizontal",
				style = "vertically_aligned_flow"
			}
			entry.add{
				type = "sprite-button",
				style = "slot_button_in_shallow_frame",
				name = "recipe-browser-open-tech-tree",
				sprite = "technology/"..tech.name,
				tags = {
					technology = tech.name
				}
			}
			entry.add{
				type = "label",
				caption = tech.localised_name
			}
		end
	end
end

---@param player LuaPlayer
---@param searched LuaItemPrototype|LuaFluidPrototype
---@param recipes LuaRecipePrototype[]
local function showRecipes(player, searched, recipes)
	local data = getGui(player)
	local content = data.components.content

	content.clear()
	for _,recipe in pairs(recipes) do
		local frame = content.add{
			type = "flow",
			direction = "horizontal",
			style = "horizontal_flow_with_extra_spacing"
		}

		local spritebox = frame.add{
			type = "frame",
			style = "deep_frame_in_shallow_frame"
		}
		spritebox.add{
			type = "sprite",
			sprite = "recipe/"..recipe.name,
			style = "recipe_browser_item_sprite"
		}

		local details = frame.add{
			type = "flow",
			direction = "vertical",
			style = "vertical_flow_with_extra_spacing"
		}
		details.add{
			type = "label",
			style = "caption_label",
			caption = recipe.localised_name
		}
		local production = details.add{
			type = "flow",
			direction = "horizontal",
			style = "vertically_aligned_flow"
		}
		local ingredients = production.add{
			type = "frame",
			style = "slot_button_deep_frame",
			direction = "horizontal"
		}
		for _,ingredient in pairs(recipe.ingredients) do
			ingredients.add{
				type = "sprite-button",
				style = "slot_button",
				sprite = ingredient.type.."/"..ingredient.name,
				tooltip = game[ingredient.type.."_prototypes"][ingredient.name].localised_name,
				number = ingredient.amount
			}
		end
		if recipe.category ~= "building" then
			ingredients.add{
				type = "sprite-button",
				style = "slot_button",
				sprite = "utility/clock",
				tooltip = {"description.crafting-time"},
				number = recipe.energy
			}
		end
		production.add{
			type = "label",
			caption = "▶"
		}
		local products = production.add{
			type = "frame",
			style = "slot_button_deep_frame",
			direction = "horizontal"
		}
		for _,product in pairs(recipe.products) do
			products.add{
				type = "sprite-button",
				style = "slot_button",
				sprite = product.type.."/"..product.name,
				tooltip = game[product.type.."_prototypes"][product.name].localised_name,
				number = (product.amount or (product.amount_min+product.amount_max)/2) * (product.probability or 1)
			}
		end
		production.add{type="empty-widget", style="filler_widget"}
		local button = production.add{
			type = "sprite-button",
			name = "recipe-browser-add-to-list",
			style = "slot_sized_button_green",
			tooltip = {"gui.recipe-browser-add-to-list"},
			sprite = "utility/reassign",
			tags = {
				recipe = recipe.name
			}
		}
		button.style.padding = 6

		button = production.add{
			type = "sprite-button",
			name = "recipe-browser-remove-from-list",
			style = "slot_sized_button_red",
			tooltip = {"gui.recipe-browser-remove-from-list"},
			sprite = "utility/trash",
			tags = {
				recipe = recipe.name
			}
		}
		button.style.padding = 6
	end
end

---@param event on_gui_closed
local function onGuiClosed(event)
	local player = game.players[event.player_index]
	closeGui(player)
end

---@param event on_gui_elem_changed
local function onGuiElemChanged(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.select_item then
		local name = event.element.elem_value
		if name then
			components.heading.caption = game.item_prototypes[name].localised_name
			components.select_fluid.elem_value = nil
			callbacks.search(player, {type="item", name=name})
		else
			components.heading.caption = {"gui.recipe-browser-select-item"}
			components.content.clear()
		end

	elseif event.element == components.select_fluid then
		local name = event.element.elem_value
		if name then
			components.heading.caption = game.fluid_prototypes[name].localised_name
			components.select_item.elem_value = nil
			callbacks.search(player, {type="fluid", name=name})
		else
			components.heading.caption = {"gui.recipe-browser-select-item"}
			components.content.clear()
		end
	end
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.close then
		closeGui(player)

	elseif event.element.name == "recipe-browser-open-tech-tree" then
		player.open_technology_gui(event.element.tags['technology'])

	elseif event.element.name == "recipe-browser-add-to-list" then
		local recipe = game.recipe_prototypes[event.element.tags['recipe']]
		local mode = "single"
		if event.button == defines.mouse_button_type.right then mode = "five" end
		if event.shift then mode = "stack" end
		callbacks.add_todo(player, recipe, mode)

	elseif event.element.name == "recipe-browser-remove-from-list" then
		local recipe = game.recipe_prototypes[event.element.tags['recipe']]
		local mode = "single"
		if event.button == defines.mouse_button_type.right then mode = "five" end
		if event.shift then mode = "stack" end
		callbacks.remove_todo(player, recipe, mode)
	end
end

return {
	open_gui = openGui,
	toggle_gui = toggleGui,
	show_techs = showTechsToUnlock,
	show_recipes = showRecipes,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.recipe_browser = global.gui.recipe_browser or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.recipe_browser or script_data
		end,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_elem_changed] = onGuiElemChanged,
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
