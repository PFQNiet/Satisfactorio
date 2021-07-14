---@class ResourceScannerGui
---@field player LuaPlayer
---@field components ResourceScannerGuiComponents

---@class ResourceScannerGuiComponents
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field scan_list LuaGuiElement
---@field scans table<string,ResourceScannerGuiScan>

---@class ResourceScannerGuiScan
---@field flow LuaGuiElement
---@field button LuaGuiElement
---@field label LuaGuiElement

---@class ResourceScannerEntryTags
---@field recipe string
---@field type string
---@field name string
---@field localised_name LocalisedString
---@field sprite SpritePath

---@alias global.gui.resource_scanner table<uint, ResourceScannerGui>
---@type global.gui.resource_scanner
local script_data = {}

---@class ResourceScannerGuiCallbacks
---@field scan fun(player:LuaPlayer, scan:string)
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
		if recipe.category == "resource-scanner" then
			table.insert(recipes, recipe)
		end
	end
	table.sort(recipes, function(a,b) return a.order < b.order end)
	getAllScans_cache = recipes
	return recipes
end

---@param player LuaPlayer
---@return ResourceScannerGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return ResourceScannerGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		direction = "vertical"
	}
	local title_flow = frame.add{type = "flow"}
	local title = title_flow.add{type = "label", caption = {"gui.resource-scanner-title"}, style = "frame_title"}
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
		caption = {"gui.resource-scanner-scan-for"}
	}

	local list = content.add{
		type = "table",
		style = "scanner_table",
		column_count = 5
	}

	local scans = {}
	for _,recipe in pairs(getAllScans()) do
		local product = recipe.main_product
		---@type LuaItemPrototype|LuaFluidPrototype
		local proto = game[product.type.."_prototypes"][product.name]
		local sprite = product.type.."/"..product.name
		local name = proto.localised_name

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
			name = "resource-scanner-scan",
			sprite = "item/item-unknown",
			style = "scanner_button",
			enabled = false
		}

		local label = flow.add{
			type = "label",
			name = "label",
			caption = {"gui.resource-scanner-unknown"}
		}

		scans[recipe.name] = {
			flow = flow,
			button = button,
			label = label
		}
	end

	script_data[player.index] = {
		player = player,
		recipe = nil,
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
		---@type ResourceScannerEntryTags
		local tags = entry.flow.tags['scan']

		local recipe = player.force.recipes[tags.recipe]
		if recipe.enabled then
			button.sprite = tags.sprite
			button.enabled = true
			label.caption = tags.localised_name
		else
			button.sprite = "item/item-unknown"
			button.enabled = false
			label.caption = {"gui.resource-scanner-unknown"}
		end
	end

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
	end
	if event.element.name == "resource-scanner-scan" then
		closeGui(player)
		---@type ResourceScannerEntryTags
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
			global.gui.resource_scanner = global.gui.resource_scanner or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.resource_scanner or script_data
		end,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
