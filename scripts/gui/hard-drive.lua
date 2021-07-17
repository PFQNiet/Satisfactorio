---@class HardDriveGui
---@field player LuaPlayer
---@field techs LuaTechnologyPrototype[]
---@field components HardDriveGuiComponents

---@class HardDriveGuiComponents
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field columns HardDriveGuiColumn[]

---@class HardDriveGuiColumn
---@field frame LuaGuiElement
---@field header LuaGuiElement
---@field sprite LuaGuiElement
---@field table LuaGuiElement
---@field description LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.hard_drive table<uint, HardDriveGui>
---@type global.gui.hard_drive
local script_data = {}

---@class HardDriveGuiCallbacks
---@field select fun(player:LuaPlayer, technology:LuaTechnologyPrototype)
local callbacks = {
	select = function() end
}

---@param player LuaPlayer
---@return HardDriveGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return HardDriveGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		direction = "vertical",
		style = "inner_frame_in_outer_frame"
	}
	local title_flow = frame.add{type = "flow"}
	local title = title_flow.add{type = "label", caption = {"gui.hard-drive-reward-title"}, style = "frame_title"}
	title.drag_target = frame
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = frame
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "hard-drive-reward-close"}

	local columns = frame.add{
		type = "flow",
		style = "horizontal_flow_with_extra_spacing"
	}
	local cols = {}
	for i=1,3 do
		local col = columns.add{
			type = "frame",
			style = "inside_shallow_frame_with_padding_and_spacing",
			direction = "vertical"
		}
		local head = col.add{
			type = "frame",
			style = "full_subheader_frame_in_padded_frame"
		}
		local caption = head.add{
			type = "label",
			style = "heading_2_label"
		}
		local list = col.add{
			type = "flow",
			direction = "vertical",
			style = "hard_drive_column_flow"
		}
		local spritebox = list.add{
			type = "frame",
			style = "deep_frame_in_shallow_frame"
		}
		local sprite = spritebox.add{
			type = "sprite",
			style = "hard_drive_recipe_sprite"
		}
		local craft = list.add{
			type = "table",
			style = "bordered_table",
			column_count = 2
		}
		local description = list.add{
			type = "label",
			style = "description_label"
		}
		list.add{type="empty-widget", style="vertical_filler_widget"}
		local button = list.add{
			type = "button",
			style = "submit_button",
			caption = {"gui.hard-drive-reward-select"}
		}

		cols[i] = {
			frame = col,
			header = caption,
			sprite = sprite,
			table = craft,
			description = description,
			button = button
		}
	end

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			close = close,
			columns = cols
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
local function updateGui(player)
	local data = getGui(player)
	local columns = data.components.columns
	for i=1,3 do columns[i].frame.visible = false end
	local getname = function(what)
		return game[what.type.."_prototypes"][what.name].localised_name
	end
	for i,tech in pairs(data.techs) do
		local col = columns[i]
		col.frame.visible = true

		local effect = tech.effects[1]
		local subtitle, image, recipe, text
		if effect.type == "unlock-recipe" then
			recipe = game.recipe_prototypes[effect.recipe]
			subtitle = recipe.localised_name
			image = "recipe/"..recipe.name
		else
			text = {"modifier-description.character-inventory-slots-bonus",effect.modifier}
			subtitle = tech.localised_name
			image = "utility/character_inventory_slots_bonus_modifier_icon"
		end

		col.header.caption = subtitle
		col.sprite.sprite = image
		if recipe then
			col.description.visible = false
			local table = col.table
			table.visible = true

			table.clear()
			for _,ingredient in pairs(recipe.ingredients) do
				table.add{
					type = "sprite",
					sprite = ingredient.type.."/"..ingredient.name
				}
				table.add{
					type = "label",
					caption = {"gui.hard-drive-recipe-ingredient",getname(ingredient),ingredient.amount}
				}
			end
			table.add{type="empty-widget"}
			table.add{
				type = "label",
				caption = {"gui.hard-drive-recipe-time",{"time-symbol-seconds-short",recipe.energy},{"description.crafting-time"}}
			}
			table.add{type="empty-widget"}
			table.add{type="empty-widget"}
			for _,product in pairs(recipe.products) do
				table.add{
					type = "sprite",
					sprite = product.type.."/"..product.name
				}
				table.add{
					type = "label",
					caption = {"gui.hard-drive-recipe-ingredient",getname(product),product.amount}
				}
			end
		else
			col.description.visible = true
			col.table.visible = false

			col.description.caption = text
		end
	end
end

---@param player LuaPlayer
---@param techs LuaTechnologyPrototype[]
---@return HardDriveGui
local function openGui(player, techs)
	local data = getGui(player)
	if not data then data = createGui(player) end
	data.techs = techs

	updateGui(player)

	local frame = data.components.frame
	player.opened = frame
	frame.visible = true
	frame.force_auto_center()
	return data
end

---@param force LuaForce
---@param techs LuaTechnologyPrototype[]
local function openAllGui(force, techs)
	for _,p in pairs(force.players) do
		if p.opened_gui_type == defines.gui_type.entity and p.opened.name == "mam" then
			openGui(p, techs)
		end
	end
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

---@param force LuaForce
local function closeAllGui(force)
	for _,p in pairs(force.players) do
		closeGui(p)
	end
end

---@param event on_gui_closed
local function onGuiClosed(event)
	local player = game.players[event.player_index]
	closeGui(player)
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

	elseif event.element == components.columns[1].button then
		closeAllGui(player.force)
		callbacks.select(player, data.techs[1])

	elseif event.element == components.columns[2].button then
		closeAllGui(player.force)
		callbacks.select(player, data.techs[2])

	elseif event.element == components.columns[3].button then
		closeAllGui(player.force)
		callbacks.select(player, data.techs[3])
	end
end

return {
	open_gui = openGui,
	force_gui = openAllGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.hard_drive = global.gui.hard_drive or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.hard_drive or script_data
		end,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
