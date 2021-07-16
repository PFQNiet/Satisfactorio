---@class BeaconScannerGui
---@field player LuaPlayer
---@field components BeaconScannerGuiComponents

---@class BeaconScannerGuiComponents
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field scan_list LuaGuiElement
---@field scans table<string,BeaconScannerGuiScan>

---@class BeaconScannerGuiScan
---@field flow LuaGuiElement
---@field button LuaGuiElement
---@field label LuaGuiElement

---@alias global.gui.beacon_scanner table<uint, BeaconScannerGui>
---@type global.gui.beacon_scanner
local script_data = {}

---@class BeaconScannerGuiCallbacks
---@field scan fun(player:LuaPlayer, scan:BeaconScannerEntryTags)
local callbacks = {
	scan = function() end
}

---@param beacon LuaEntity
---@return LuaCustomChartTag
local function findBeaconTag(beacon)
	local pos = beacon.position
	return beacon.force.find_chart_tags(beacon.surface, {{pos.x-0.1,pos.y-0.1},{pos.x+0.1,pos.y+0.1}})[1]
end

---@param player LuaPlayer
---@return BeaconScannerGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return BeaconScannerGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local frame = player.gui.screen.add{
		type = "frame",
		direction = "vertical",
		style = "inner_frame_in_outer_frame"
	}
	local title_flow = frame.add{type = "flow"}
	local title = title_flow.add{type = "label", caption = {"gui.beacon-scanner-title"}, style = "frame_title"}
	title.drag_target = frame
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = frame
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white"}

	local content = frame.add{
		type = "frame",
		style = "inside_shallow_frame",
		direction = "vertical"
	}
	local head = content.add{
		type = "frame",
		style = "full_subheader_frame"
	}
	head.add{
		type = "label",
		style = "heading_2_label",
		caption = {"gui.beacon-scanner-scan-for"}
	}

	local body = content.add{
		type = "scroll-pane",
		style = "scanner_scroll_pane"
	}

	local list = body.add{
		type = "table",
		style = "scanner_table",
		column_count = 6
	}

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			close = close,
			scan_list = list,
			scans = {}
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@return boolean Success if there is at least one beacon to scan for
local function openGui(player)
	local data = getGui(player)
	if not data then data = createGui(player) end

	local menu = data.components.scan_list
	menu.clear()
	local entities = player.surface.find_entities_filtered{name="map-marker",force=player.force}
	local tags = {}
	for _,beacon in pairs(entities) do
		tags[beacon.unit_number] = findBeaconTag(beacon)
	end
	-- sort beacons alphabetically... to help :D
	table.sort(entities, function(a,b)
		if tags[a.unit_number].text ~= tags[b.unit_number].text then
			return tags[a.unit_number].text < tags[b.unit_number].text
		elseif tags[a.unit_number].icon.type ~= tags[b.unit_number].icon.type then
			return tags[a.unit_number].icon.type < tags[b.unit_number].icon.type
		elseif tags[a.unit_number].icon.name ~= tags[b.unit_number].icon.name then
			return tags[a.unit_number].icon.name < tags[b.unit_number].icon.name
		else
			return a.unit_number < b.unit_number
		end
	end)

	local scans = {}
	local use_minimap = player.minimap_enabled
	for _,beacon in pairs(entities) do
		local tag = tags[beacon.unit_number]
		local type = tag.icon.type
		if type == "virtual" then type = "virtual-signal" end
		local icon = type.."/"..tag.icon.name
		local name = tag.text == "" and {"entity-name.map-marker"} or tag.text
		local tagdata = {
			scan = {
				icon = icon,
				name = name,
				position = beacon.position
			}
		}

		local flow = menu.add{
			type = "flow",
			direction = "vertical",
			style = "scanner_flow"
		}

		local button
		if use_minimap then
			local mapframe = flow.add{
				type = "frame",
				style = "deep_frame_in_shallow_frame"
			}
			button = mapframe.add{
				type = "minimap",
				name = "beacon-scanner-select",
				style = "scanner_minimap",
				position = beacon.position,
				surface_index = beacon.surface.index,
				tags = tagdata
			}
		else
			button = flow.add{
				type = "sprite-button",
				name = "beacon-scanner-select",
				sprite = icon,
				style = "scanner_button",
				tags = tagdata
			}
		end

		local label = flow.add{
			type = "label",
			name = "label",
			caption = {"", "[img="..icon.."] ", name}
		}

		scans[beacon.unit_number] = {
			flow = flow,
			button = button,
			label = label
		}
	end
	data.components.scans = scans

	local frame = data.components.frame
	if #entities == 0 then
		frame.visible = false
		return false
	else
		frame.visible = true
		player.opened = frame
		frame.force_auto_center()
		return true
	end
end

---@param player LuaPlayer
local function closeGui(player)
	local data = getGui(player)
	if not data then return end
	if player.opened == data.components.frame then
		player.opened = nil
	end
	data.components.scans = {}
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
	if event.element.name == "beacon-scanner-select" then
		closeGui(player)
		---@type BeaconScannerEntryTags
		local tags = event.element.tags['scan']
		callbacks.scan(player, tags)
	end
end

return {
	open_gui = openGui,
	toggle_gui = toggleGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.beacon_scanner = global.gui.beacon_scanner or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.beacon_scanner or script_data
		end,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
