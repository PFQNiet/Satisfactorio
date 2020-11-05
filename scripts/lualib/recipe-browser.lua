-- provides both a recipe browser and an ingredient-gathering list for the player
-- uses global['wanted-items'] to track a player's list of things
local util = require("util")

local function getRecipeYield(recipe)
	return (recipe.main_product and recipe.main_product.amount or recipe.products[1].amount) or 1
end

local function openRecipeGui(player)
	local gui = player.gui.screen['recipe-browser']
	if not gui then
		gui = player.gui.screen.add{
			type = "frame",
			name = "recipe-browser",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = gui.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.recipe-browser-title"}, style = "frame_title"}
		title.drag_target = gui
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
		pusher.style.height = 24
		pusher.style.horizontally_stretchable = true
		pusher.drag_target = gui
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "recipe-browser-close"}

		local content = gui.add{
			type = "frame",
			style = "inside_shallow_frame",
			direction = "vertical",
			name = "content"
		}
		local heading = content.add{
			type = "frame",
			style = "subheader_frame",
			direction = "horizontal",
			name = "header"
		}
		heading.style.horizontally_stretchable = true
		heading.add{
			type = "choose-elem-button",
			elem_type = "item",
			name = "recipe-browser-choose-item"
		}
		heading.add{
			type = "choose-elem-button",
			elem_type = "fluid",
			name = "recipe-browser-choose-fluid"
		}
		heading.add{
			type = "label",
			caption = {"gui.recipe-browser-select-item"},
			style = "heading_2_label"
		}

		local scroll = content.add{
			type = "scroll-pane",
			name = "recipe-container",
			style = "scroll_pane_under_subheader",
			horizontal_scroll_policy = "never",
			vertical_scroll_policy = "always"
		}
		scroll.style.width = 520
		scroll.style.height = 400
		local recipes = scroll.add{
			type = "table",
			column_count = 1,
			style = "bordered_table",
			name = "recipes"
		}
		recipes.style.margin = 12
		recipes.style.vertical_spacing = 12
		recipes.style.horizontally_stretchable = true
		gui.visible = false
	end

	if gui.visible then
		gui.visible = false
	else
		gui.visible = true
		player.opened = gui
		gui.force_auto_center()
	end
end

local function updateWantedList(player)
	local gui = player.gui.screen['to-do-list']
	if not gui then
		gui = player.gui.screen.add{
			type = "frame",
			name = "to-do-list",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = gui.add{type = "flow", name = "title_flow"}
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/collapse", name = "to-do-list-toggle"}.style.right_margin = 6
		local title = title_flow.add{type = "label", caption = {"gui.to-do-title"}, style = "frame_title"}
		title.drag_target = gui
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
		pusher.style.height = 24
		pusher.style.horizontally_stretchable = true
		pusher.drag_target = gui
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "to-do-list-close"}

		local content = gui.add{
			type = "frame",
			style = "inside_shallow_frame",
			direction = "vertical",
			name = "content"
		}
		local wanted = content.add{
			type = "frame",
			style = "slot_button_deep_frame",
			name = "wanted"
		}
		wanted.style.minimal_height = 40
		wanted.style.width = 200
		wanted.style.margin = 12
		wanted.add{
			type = "table",
			style = "filter_slot_table",
			column_count = 5,
			name = "to-do-list-wanted"
		}
		local list = content.add{
			type = "scroll-pane",
			name = "list",
			style = "scroll_pane_in_shallow_frame",
			horizontal_scroll_policy = "never",
			vertical_scroll_policy = "always"
		}
		list.style.width = 224
		list.style.padding = 12
		list.style.maximal_height = 400
		local table = list.add{
			type = "flow",
			name = "to-do-list-ingredients",
			direction = "vertical"
		}
		table.style.vertical_spacing = 12
		table.style.horizontally_stretchable = true

		gui.location = {player.display_resolution.width-512*player.display_scale, 40*player.display_scale}
	end
	gui.visible = true

	local wanted = gui.content.wanted['to-do-list-wanted']
	local list = gui.content.list['to-do-list-ingredients']
	local ingredients = {}

	wanted.clear()
	for name,count in pairs(global['wanted-items'][player.index]) do
		local recipe = game.recipe_prototypes[name]
		wanted.add{
			type = "sprite-button",
			style = "slot_button",
			sprite = "recipe/"..recipe.name,
			tooltip = recipe.localised_name,
			number = count
		}
		local yield = getRecipeYield(recipe)
		for _,ingredient in pairs(recipe.ingredients) do
			local key = ingredient.type.."/"..ingredient.name
			if not ingredients[key] then
				ingredients[key] = {
					type = ingredient.type,
					name = ingredient.name,
					localised_name = game[ingredient.type.."_prototypes"][ingredient.name].localised_name,
					amount = 0
				}
			end
			ingredients[key].amount = ingredients[key].amount + ingredient.amount * count / yield
		end
	end
	-- convert dictionary to array for sorting
	local ings = {}
	for _,i in pairs(ingredients) do table.insert(ings,i) end
	table.sort(ings, function(a,b)
		return a.type.."/"..a.name < b.type.."/"..b.name
	end)
	
	local inventory = player.get_main_inventory().get_contents()
	list.clear()
	for _,ingredient in pairs(ings) do
		local item = ingredient.name
		if ingredient.type == "fluid" and game.item_prototypes["packaged-"..ingredient.name] then
			-- accept packaged version for inventory checking
			item = "packaged-"..ingredient.name
		end
		local entry = list.add{
			type = "flow",
			direction = "horizontal"
		}
		entry.style.vertical_align = "center"
		local left = entry.add{
			type = "flow",
			direction = "vertical"
		}
		left.style.horizontally_stretchable = true
		local top = left.add{
			type = "flow",
			direction = "horizontal"
		}
		top.add{
			type = "label",
			caption = ingredient.localised_name
		}.style.horizontally_squashable = true
		top.add{type="empty-widget"}.style.horizontally_stretchable = true
		top.add{
			type = "label",
			caption = {"gui.fraction",util.format_number(inventory[item] or 0),util.format_number(ingredient.amount)}
		}
		local bar = left.add{
			type = "progressbar",
			value = (inventory[item] or 0) / ingredient.amount
		}
		bar.style.horizontally_stretchable = true

		entry.add{
			type = "sprite-button",
			style = "slot_button_in_shallow_frame",
			sprite = ingredient.type.."/"..ingredient.name,
			tooltip = ingredient.localised_name
		}
	end
end
local function editItemRequestCount(player,source)
	-- determine which slot was clicked
	local index = 0
	for i,slot in pairs(source.parent.children) do
		if slot == source then
			index = i
			break
		end
	end
	if index == 0 then return end
	source.style = "yellow_slot_button"

	local name
	local count = index
	for key,_ in pairs(global['wanted-items'][player.index]) do
		count = count - 1
		if count == 0 then
			name = key
			break
		end
	end
	local number = math.ceil(source.number)

	local mask = player.gui.screen['to-do-request-mask']
	if mask then mask.destroy() end
	mask = player.gui.screen.add{
		type = "frame",
		name = "to-do-request-mask",
		style = "invisible_frame"
	}
	mask.style.width = player.display_resolution.width / player.display_scale
	mask.style.height = player.display_resolution.height / player.display_scale
	mask.location = {0,0}

	local gui = player.gui.screen['to-do-request-number']
	if gui then gui.destroy() end
	gui = player.gui.screen.add{
		type = "frame",
		name = "to-do-request-number",
		style = "inner_frame_in_outer_frame"
	}
	gui.style.vertical_align = "center"
	local flow = gui.add{
		type = "flow",
		direction = "horizontal",
		name = name -- data stash :D
	}

	local input = flow.add{
		type = "textfield",
		name = "to-do-request-number-input",
		numeric = true,
		text = number,
		allow_decimal = false,
		allow_negative = false,
		lose_focus_on_confirm = true
	}
	input.style.width = 50
	local addbtn = flow.add{
		type = "sprite-button",
		name = "to-do-request-confirm",
		style = "tool_button_green",
		tooltip = {"gui.confirm"},
		sprite = "utility.confirm_slot"
	}
	local delbtn = flow.add{
		type = "sprite-button",
		name = "to-do-request-delete",
		style = "tool_button_red",
		tooltip = {"gui.delete"},
		sprite = "utility.trash"
	}

	local loc = player.gui.screen['to-do-list'].location
	gui.location = {
		loc.x + 24 + ((index-1)%5)/4*62,
		loc.y + 92 + math.floor((index-1)/5)*40
	}
end
local function closeItemRequestCount(player)
	for _,slot in pairs(player.gui.screen['to-do-list'].content.wanted['to-do-list-wanted'].children) do slot.style = "slot_button" end
	player.gui.screen['to-do-request-mask'].destroy()
	player.gui.screen['to-do-request-number'].destroy()
end
local function updateItemRequestCount(player, name, count)
	if count == 0 then
		global['wanted-items'][player.index][name] = nil
		if table_size(global['wanted-items'][player.index]) == 0 then
			player.gui.screen['to-do-list'].visible = false
			global['wanted-items'][player.index] = nil
		else
			updateWantedList(player)
		end
	else
		local yield = getRecipeYield(game.recipe_prototypes[name])
		global['wanted-items'][player.index][name] = math.ceil(count / yield) * yield
		updateWantedList(player)
	end
	closeItemRequestCount(player)
end

local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "recipe-browser" then
		event.element.visible = false
	end
end

local function onGuiElemChanged(event)
	if event.element and event.element.valid and (event.element.name == "recipe-browser-choose-item" or event.element.name == "recipe-browser-choose-fluid") then
		local player = game.players[event.player_index]
		local parent = event.element.parent
		parent[event.element.name == "recipe-browser-choose-item" and "recipe-browser-choose-fluid" or "recipe-browser-choose-item"].elem_value = nil
		local search = {
			type = event.element.name == "recipe-browser-choose-item" and "item" or "fluid",
			name = event.element.elem_value
		}
		local gui = player.gui.screen['recipe-browser'].content['recipe-container'].recipes
		gui.clear()
		if search.name then
			local matching_recipes = {}
			local potential_recipes = {}
			for _,recipe in pairs(player.force.recipes) do
				if not recipe.prototype.hidden_from_player_crafting and recipe.prototype.category ~= "unbuilding" then
					-- check if any products match
					local match = false
					for _,product in pairs(recipe.products) do
						if product.type == search.type and product.name == search.name then
							match = true
							break
						end
					end
					if match then
						-- "potential" is used if no matching one is found, to show techs to unlock. therefore, ignore by-product recipes for this
						potential_recipes[recipe.name] = (not recipe.prototype.main_product) or (recipe.prototype.main_product.type == search.type and recipe.prototype.main_product.name == search.name)
						if recipe.enabled then
							table.insert(matching_recipes, recipe)
						end
					end
				end
			end
			if #matching_recipes == 0 then
				local nomatch = gui.add{
					type = "label",
					style = "heading_2_label",
					caption = {"gui.recipe-browser-no-recipe",game[search.type.."_prototypes"][search.name].localised_name}
				}
				nomatch.style.horizontally_stretchable = true
				-- find tech(s) that unlock this, but exclude alt-recipe techs, except alt-exclusive recipes
				local techs = {}
				local alt_only = {
					["alt-heavy-oil-residue"] = true,
					["alt-polymer-resin"] = true,
					["alt-compacted-coal"] = true,
					["alt-turbofuel"] = true
				}
				for _,tech in pairs(player.force.technologies) do
					if tech.research_unit_ingredients[1].name ~= "hard-drive" or alt_only[tech.name] then
						for _,result in pairs(tech.effects) do
							if result.type == "unlock-recipe" and potential_recipes[result.recipe] then
								table.insert(techs,tech)
								break
							end
						end
					end
				end
				if #techs == 0 then
					nomatch.caption = {"gui.recipe-browser-no-technology-either",game[search.type.."_prototypes"][search.name].localised_name}
					gui.add{
						type = "label",
						caption = {"gui.recipe-browser-maybe-in-wild"}
					}
				else
					local techlist = gui.add{
						type = "flow",
						direction = "vertical"
					}
					techlist.add{
						type = "label",
						style = "caption_label",
						caption = {"gui.recipe-browser-tech-unlock",#techs}
					}
					for i,tech in ipairs(techs) do
						local entry = techlist.add{
							type = "flow",
							direction = "horizontal",
							name = tech.name -- stash some data here!
						}
						entry.style.vertical_align = "center"
						local sprite = entry.add{
							type = "sprite-button",
							style = "slot_button_in_shallow_frame",
							name = "recipe-browser-open-tech-tree",
							sprite = "technology/"..tech.name
						}
						entry.add{
							type = "label",
							caption = tech.localised_name
						}
					end
				end
			else
				table.sort(matching_recipes, function(a,b)
					-- prioritise recipes where the main product doesn't exist, or is the searched product
					local a_main = (not a.prototype.main_product) or (a.prototype.main_product.type == search.type and a.prototype.main_product.name == search.name)
					local b_main = (not b.prototype.main_product) or (b.prototype.main_product.type == search.type and b.prototype.main_product.name == search.name)
					if a_main ~= b_main then
						return a_main
					elseif a.group ~= b.group then
						return a.group.order < b.group.order
					elseif a.subgroup ~= b.subgroup then
						return a.subgroup.order < b.subgroup.order
					else
						return a.prototype.order < b.prototype.order
					end
				end)
				for _,recipe in pairs(matching_recipes) do
					local frame = gui.add{
						type = "flow",
						direction = "horizontal",
						name = recipe.name
					}
					frame.style.horizontal_spacing = 12

					local spritebox = frame.add{
						type = "frame",
						style = "deep_frame_in_shallow_frame"
					}
					spritebox.style.padding = 4
					local sprite = spritebox.add{
						type = "sprite",
						sprite = "recipe/"..recipe.name
					}
					sprite.style.width = 64
					sprite.style.height = 64
					sprite.style.stretch_image_to_widget_size = true

					local details = frame.add{
						type = "flow",
						direction = "vertical"
					}
					details.style.vertical_spacing = 12
					details.style.horizontally_stretchable = true
					details.add{
						type = "label",
						style = "caption_label",
						caption = recipe.localised_name
					}
					local production = details.add{
						type = "flow",
						direction = "horizontal",
					}
					production.style.vertical_align = "center"
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
					ingredients.add{
						type = "sprite-button",
						style = "slot_button",
						sprite = "utility/clock",
						tooltip = {"description.crafting-time"},
						number = recipe.energy
					}
					production.add{
						type = "label",
						caption = {"gui.recipe-browser-craft"}
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
					local spacer = production.add{type = "empty-widget"}
					spacer.style.horizontally_stretchable = true
					local button = production.add{
						type = "sprite-button",
						name = "recipe-browser-add-to-list",
						style = "slot_sized_button_green",
						tooltip = {"gui.recipe-browser-add-to-list"},
						sprite = "utility.add"
					}
				end
			end
		end
	end
end

local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "recipe-browser-close" then
		player.gui.screen['recipe-browser'].visible = false
		player.opened = nil
	elseif event.element.name == "recipe-browser-open-tech-tree" then
		player.open_technology_gui(event.element.parent.name)
	elseif event.element.name == "recipe-browser-add-to-list" then
		local recipe = game.recipe_prototypes[event.element.parent.parent.parent.name]
		if not global['wanted-items'] then global['wanted-items'] = {} end
		if not global['wanted-items'][player.index] then global['wanted-items'][player.index] = {} end
		local yield = getRecipeYield(recipe)
		global['wanted-items'][player.index][recipe.name] = (global['wanted-items'][player.index][recipe.name] or 0) + yield
		updateWantedList(player)
	elseif event.element.name == "to-do-list-toggle" then
		local elem = player.gui.screen['to-do-list'].content
		if elem.visible then
			elem.visible = false
			event.element.sprite = "utility/expand"
		else
			elem.visible = true
			event.element.sprite = "utility/collapse"
		end
	elseif event.element.name == "to-do-list-close" then
		player.gui.screen['to-do-list'].visible = false
		global['wanted-items'][player.index] = nil
	elseif event.element.parent and event.element.parent.valid and event.element.parent.name == "to-do-list-wanted" then
		editItemRequestCount(player, event.element)
	elseif event.element.name == "to-do-request-confirm" then
		local flow = event.element.parent
		local count = tonumber(flow['to-do-request-number-input'].text)
		updateItemRequestCount(player, flow.name, count)
	elseif event.element.name == "to-do-request-delete" then
		local flow = event.element.parent
		updateItemRequestCount(player, flow.name, 0)
	elseif event.element.name == "to-do-request-mask" then
		closeItemRequestCount(player)
	end
end
local function onGuiConfirmed(event)
	if event.element and event.element.valid and event.element.name == "to-do-request-number-input" then
		local player = game.players[event.player_index]
		local flow = event.element.parent
		local count = tonumber(flow['to-do-request-number-input'].text)
		updateItemRequestCount(player, flow.name, count)
	end
end

local function onInventoryChanged(event)
	local player = game.players[event.player_index]
	if global['wanted-items'] and global['wanted-items'][player.index] then
		updateWantedList(player)
	end
end

return {
	events = {
		["recipe-browser"] = function(event)
			openRecipeGui(game.players[event.player_index])
		end,
		[defines.events.on_lua_shortcut] = function(event)
			if event.prototype_name == "recipe-browser" then
				openRecipeGui(game.players[event.player_index])
			end
		end,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_elem_changed] = onGuiElemChanged,
		[defines.events.on_gui_confirmed] = onGuiConfirmed,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_player_main_inventory_changed] = onInventoryChanged
	}
}
