---@class ObjectScannerGui
---@field player LuaPlayer
---@field components ObjectScannerGuiComponents

---@class ObjectScannerGuiComponents
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field scan_list LuaGuiElement
---@field scans table<string,ObjectScannerGuiScan>

---@class ObjectScannerGuiScan
---@field flow LuaGuiElement
---@field button LuaGuiElement
---@field label LuaGuiElement

---@alias global.gui.object_scanner table<uint, ObjectScannerGui>
---@type global.gui.object_scanner
local script_data = {}

---@class ObjectScannerGuiCallbacks
---@field scan fun(player:LuaPlayer, scan:ObjectScannerEntryTags)
local callbacks = {
	scan = function() end
}

---@type LuaRecipePrototype[]
local getAllScans_cache = nil
---@return LuaRecipePrototype[]
local function getAllScans()
	if getAllScans_cache then return getAllScans_cache end
	local recipes = {}
	for _,recipe in pairs(game.recipe_prototypes) do
		if recipe.category == "object-scanner" then
			table.insert(recipes, recipe)
		end
	end
	table.sort(recipes, function(a,b) return a.order < b.order end)
	getAllScans_cache = recipes
	return recipes
end

---@param player LuaPlayer
---@return ObjectScannerGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return ObjectScannerGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		direction = "vertical"
	}
	local title_flow = frame.add{type = "flow"}
	local title = title_flow.add{type = "label", caption = {"gui.object-scanner-title"}, style = "frame_title"}
	title.drag_target = frame
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = frame
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white"}

	local content = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding_and_spacing",
		direction = "vertical"
	}
	local head = content.add{
		type = "frame",
		style = "full_subheader_frame_in_padded_frame"
	}
	head.add{
		type = "label",
		style = "heading_2_label",
		caption = {"gui.object-scanner-scan-for"}
	}

	local list = content.add{
		type = "table",
		style = "scanner_table",
		column_count = 4
	}

	local scans = {}
	for _,recipe in pairs(getAllScans()) do
		local product = recipe.main_product
		---@type LuaItemPrototype|LuaFluidPrototype
		local proto = game[product.type.."_prototypes"][product.name]
		local sprite = product.type.."/"..product.name
		local name = proto.localised_name
		if product.name == "green-power-slug" then name = {"gui.object-scanner-power-slugs"} end

		local flow = list.add{
			type = "flow",
			direction = "vertical",
			style = "scanner_flow",
			tags = {
				scan = {
					recipe = recipe.name,
					type = product.type,
					name = product.name,
					localised_name = name,
					sprite = sprite
				}
			}
		}

		local button = flow.add{
			type = "sprite-button",
			name = "object-scanner-select",
			sprite = "item/item-unknown",
			style = "scanner_button",
			enabled = false
		}

		local label = flow.add{
			type = "label",
			name = "label",
			caption = {"gui.object-scanner-unknown"}
		}

		scans[recipe.name] = {
			flow = flow,
			button = button,
			label = label
		}
	end

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			close = close,
			scan_list = list,
			scans = scans
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
local function openGui(player)
	local data = getGui(player)
	if not data then data = createGui(player) end

	for _,entry in pairs(data.components.scans) do
		local button = entry.button
		local label = entry.label
		---@type ObjectScannerEntryTags
		local tags = entry.flow.tags['scan']

		local recipe = player.force.recipes[tags.recipe]
		if recipe.enabled then
			button.sprite = tags.sprite
			button.enabled = true
			label.caption = tags.localised_name
		else
			button.sprite = "item/item-unknown"
			button.enabled = false
			label.caption = {"gui.object-scanner-unknown"}
		end
	end

	local frame = data.components.frame
	player.opened = frame
	frame.visible = true
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
end

---@param player LuaPlayer
local function toggleGui(player)
	local data = getGui(player)
	if not data then return openGui(player) end
	if data.components.frame.visible then return closeGui(player) end
	return openGui(player)
end

---@param event on_gui_closed
local function onGuiClosed(event)
	if event.gui_type ~= defines.gui_type.custom then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	if event.element == data.components.frame then
		data.components.frame.visible = false
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
	end
	if event.element.name == "object-scanner-select" then
		closeGui(player)
		---@type ObjectScannerEntryTags
		local tags = event.element.parent.tags['scan']
		callbacks.scan(player, tags)
	end
end

return {
	open_gui = openGui,
	toggle_gui = toggleGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.object_scanner = global.gui.object_scanner or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.object_scanner or script_data
		end,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
