local bev = require(modpath.."scripts.lualib.build-events")

---@class DronePortGui
---@field player LuaPlayer
---@field struct DronePortData
---@field components DronePortGuiComponents

---@class DronePortGuiComponents
---@field container LuaGuiElement
---@field tabs LuaGuiElement
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field name LuaGuiElement
---@field rename DronePortRenameGuiComponents
---@field status DronePortStatusGuiComponents
---@field minimap DronePortMinimapGuiComponents
---@field destination DronePortDestinationGuiComponents
---@field stats DronePortStatsGuiComponents

---@class DronePortRenameGuiComponents
---@field name_flow LuaGuiElement
---@field button LuaGuiElement
---@field flow LuaGuiElement
---@field input LuaGuiElement
---@field confirm LuaGuiElement
---@field cancel LuaGuiElement

---@class DronePortStatusGuiComponents
---@field icon LuaGuiElement
---@field label LuaGuiElement

---@class DronePortMinimapGuiComponents
---@field flow LuaGuiElement
---@field map LuaGuiElement

---@class DronePortDestinationGuiComponents
---@field name LuaGuiElement
---@field map LuaGuiElement
---@field select LuaGuiElement
---@field search_flow LuaGuiElement
---@field search_input LuaGuiElement
---@field search_results LuaGuiElement

---@class DronePortStatsGuiComponents
---@field table LuaGuiElement
---@field distance LuaGuiElement
---@field time LuaGuiElement
---@field batteries LuaGuiElement
---@field throughput LuaGuiElement

---@alias global.gui.drone_port table<uint, DronePortGui>
---@type global.gui.drone_port
local script_data = {}

---@class DronePortGuiCallbacks
---@field rename fun(player:LuaPlayer, port:DronePortData, name:string)
---@field search fun(player:LuaPlayer, opened:DronePortData, query:string):DronePortData[]
---@field set_destination fun(player:LuaPlayer, port:DronePortData, destination_id:uint)
---@field map_destination fun(player:LuaPlayer, port:DronePortData)
---@field map_drone fun(player:LuaPlayer, port:DronePortData)
local callbacks = {
	rename = function() end,
	search = function() end,
	set_destination = function() end,
	map_destination = function() end,
	map_drone = function() end
}

---@param player LuaPlayer
---@return DronePortGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return DronePortGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local secret_flow = gui.add{
		type = "frame",
		direction = "vertical",
		style = "invisible_frame"
	}
	local tabs = secret_flow.add{
		type = "tabbed-pane",
		style = "tabbed_pane_with_no_side_padding_and_tabs_hidden"
	}
	tabs.add_tab(
		tabs.add{type = "tab", caption = {"gui.station-drone"}},
		tabs.add{type="empty-widget"}
	)
	tabs.add_tab(
		tabs.add{type = "tab", caption = {"gui.station-fuel-box"}},
		tabs.add{type="empty-widget"}
	)
	tabs.add_tab(
		tabs.add{type = "tab", caption = {"gui.station-export"}},
		tabs.add{type="empty-widget"}
	)
	tabs.add_tab(
		tabs.add{type = "tab", caption = {"gui.station-import"}},
		tabs.add{type="empty-widget"}
	)

	local frame = secret_flow.add{
		type = "frame",
		direction = "vertical",
		style = "inner_frame_in_outer_frame"
	}

	local title_flow = frame.add{type = "flow"}
	local name_flow = title_flow.add{type = "flow"}
	name_flow.drag_target = secret_flow
	local name = name_flow.add{type = "label", style = "frame_title"}
	local rename = name_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/rename_icon_small_white"}
	local rename_flow = title_flow.add{type = "flow", name = "rename_flow", visible = false}
	local rename_input = rename_flow.add{type = "textfield", lose_focus_on_confirm = true}
	local rename_confirm = rename_flow.add{
		type = "sprite-button",
		style = "tool_button_green",
		tooltip = {"gui.confirm"},
		sprite = "utility/check_mark_white"
	}
	local rename_cancel = rename_flow.add{
		type = "sprite-button",
		style = "tool_button_red",
		tooltip = {"gui.dear-wube-cancel-means-cancel-not-back-thank-you-very-much"},
		sprite = "utility/close_black"
	}
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = secret_flow
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white"}

	local inner = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding_and_spacing",
		direction = "vertical"
	}
	local status_flow = inner.add{
		type = "flow",
		style = "status_flow"
	}
	status_flow.style.vertical_align = "center"
	local status_icon = status_flow.add{
		type = "sprite",
		style = "status_image"
	}
	local status_caption = status_flow.add{
		type = "label"
	}

	local minimap_flow = inner.add{type = "flow", direction = "horizontal"}
	minimap_flow.add{type="empty-widget", style="filler_widget"}
	local minimap_frame = minimap_flow.add{
		type = "frame",
		style = "deep_frame_in_shallow_frame"
	}
	local minimap = minimap_frame.add{
		type = "minimap",
		tooltip = {"gui-train.open-in-map"}
	}
	minimap_flow.add{type="empty-widget", style="filler_widget"}

	local destination_flow = inner.add{
		type = "flow",
		style = "vertically_aligned_flow"
	}
	destination_flow.add{
		type = "label",
		style = "caption_label",
		caption = {"gui.drone-destination"}
	}
	local destination_name = destination_flow.add{
		type = "label",
		caption = {"gui.drone-destination-not-set"}
	}
	destination_name.style.maximal_width = 300
	local destination_select = destination_flow.add{
		type = "sprite-button",
		style = "tool_button",
		sprite = "utility/change_recipe",
		tooltip = {"gui.drone-destination-select"}
	}
	local destination_map = destination_flow.add{
		type = "sprite-button",
		style = "tool_button",
		sprite = "utility/map",
		tooltip = {"gui-train.open-in-map"}
	}

	local search_flow = inner.add{
		type = "flow",
		direction = "vertical",
		visible = false
	}
	local search_input = search_flow.add{
		type = "textfield",
		style = "stretched_textbox",
		lose_focus_on_confirm = true
	}
	local search_results = search_flow.add{
		type = "list-box",
		style = "drone_port_destination_list_box",
		tags = {
			['search-ids'] = {}
		}
	}
	search_flow.add{
		type = "label",
		style = "multiline_label",
		caption = {"gui.drone-destination-update-on-takeoff"}
	}

	local stats_table = inner.add{type = "flow", direction = "vertical"}
	local flow = stats_table.add{type = "flow", direction = "horizontal"}
	flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-distance"}}
	local stats_distance = flow.add{type = "label", caption = {"gui.drone-stats-na"}}

	flow = stats_table.add{type = "flow", direction = "horizontal"}
	flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-time"}}
	local stats_time = flow.add{type = "label", caption = {"gui.drone-stats-na"}}

	flow = stats_table.add{type = "flow", direction = "horizontal"}
	flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-batteries"}}
	local stats_batteries = flow.add{type = "label", caption = {"gui.drone-stats-na"}}
	flow.add{type = "label", caption = "[img=info]", tooltip = {"gui.drone-stats-batteries-info"}}

	flow = stats_table.add{type = "flow", direction = "horizontal"}
	flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-throughput"}}
	local stats_throughput = flow.add{type = "label", caption = {"gui.drone-stats-na"}}

	script_data[player.index] = {
		player = player,
		port = nil,
		components = {
			container = secret_flow,
			tabs = tabs,
			frame = frame,
			close = close,
			name = name,
			rename = {
				name_flow = name_flow,
				button = rename,
				flow = rename_flow,
				input = rename_input,
				confirm = rename_confirm,
				cancel = rename_cancel
			},
			status = {
				icon = status_icon,
				label = status_caption
			},
			minimap = {
				flow = minimap_flow,
				map = minimap
			},
			destination = {
				name = destination_name,
				map = destination_map,
				select = destination_select,
				search_flow = search_flow,
				search_input = search_input,
				search_results = search_results
			},
			stats = {
				table = stats_table,
				distance = stats_distance,
				time = stats_time,
				batteries = stats_batteries,
				throughput = stats_throughput
			}
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param name string
local function updateName(player, name)
	local data = getGui(player)
	if not data then return end
	data.components.name.caption = name
	data.components.rename.name_flow.visible = true
	data.components.rename.flow.visible = false
end

---@param player LuaPlayer
---@param status DronePortStatus
local function updateStatus(player, status)
	local data = getGui(player)
	if not data then return end
	data.components.status.icon.sprite = status.sprite
	data.components.status.label.caption = status.caption
end

---@param player LuaPlayer
---@param target LuaEntity
local function updateMinimap(player, target)
	local data = getGui(player)
	if not data then return end
	data.components.minimap.flow.visible = player.minimap_enabled
	data.components.minimap.map.surface_index = target.surface.index
	data.components.minimap.map.entity = target
end

---@param player LuaPlayer
---@param destination DronePortData|nil
local function updateDestination(player, destination)
	local data = getGui(player)
	if not data then return end
	data.components.destination.name.caption = destination and destination.name or {"gui.drone-destination-not-set"}
	data.components.destination.map.visible = player.minimap_enabled
	data.components.destination.search_flow.visible = false
	data.components.stats.table.visible = true
end

---@param player LuaPlayer
---@param stats DroneTravelStats
local function updateStatistics(player, stats)
	local data = getGui(player)
	if not data then return end
	local stats_table = data.components.stats
	if not stats then
		stats_table.distance.caption = {"gui.drone-stats-na"}
		stats_table.time.caption = {"gui.drone-stats-na"}
		stats_table.batteries.caption = {"gui.drone-stats-na"}
		stats_table.throughput.caption = {"gui.drone-stats-na"}
	else
		local distance = math.floor(stats.distance/10)/100 -- km to 2 decimal places
		local time = math.floor(stats.time)
		local throughput = math.floor(9 / (stats.time/60) * 100) / 100 -- stacks per minute, to 2 decimal places
		stats_table.distance.caption = {"gui.drone-stats-distance-value", distance}
		stats_table.time.caption = {"gui.drone-stats-time-value", math.floor(time/60), time%60<10 and "0" or "", time%60}
		stats_table.batteries.caption = {"gui.drone-stats-batteries-value", math.ceil(stats.batteries)}
		stats_table.throughput.caption = {"gui.drone-stats-throughput-value", throughput}
	end
end

---@param player LuaPlayer
---@param struct DronePortData
local function openGui(player, struct, status, destination, stats)
	local data = getGui(player)
	if not data then data = createGui(player) end
	local components = data.components

	components.tabs.selected_tab_index = 1
	updateName(player, struct.name)
	updateStatus(player, status)
	updateMinimap(player, struct.drone or struct.base)
	updateDestination(player, destination)
	updateStatistics(player, stats)

	local frame = components.container
	player.opened = frame
	frame.visible = true
	frame.force_auto_center()

	data.struct = struct
	return data
end

-- for anyone who has this port open, update its name
---@param struct DronePortData
local function updateNameForAll(struct)
	for _,p in pairs(game.players) do
		local data = getGui(p)
		if data and data.struct == struct then
			updateName(p, struct.name)
		end
	end
end

-- for anyone who has this port open, update its status
---@param struct DronePortData
---@param status DronePortStatus
local function updateStatusForAll(struct, status)
	for _,p in pairs(game.players) do
		local data = getGui(p)
		if data and data.struct == struct then
			updateStatus(p, status)
		end
	end
end

-- for anyone who has this port open, update its minimap
---@param struct DronePortData
local function updateMinimapForAll(struct)
	for _,p in pairs(game.players) do
		local data = getGui(p)
		if data and data.struct == struct then
			updateMinimap(p, struct.drone or struct.base)
		end
	end
end

-- for anyone who has this port open, update its destination
---@param struct DronePortData
---@param destination DronePortData
local function updateDestinationForAll(struct, destination)
	for _,p in pairs(game.players) do
		local data = getGui(p)
		if data and data.struct == struct then
			updateDestination(p, destination)
		end
	end
end

-- for anyone who has this port open, update its statistics
---@param struct DronePortData
---@param stats DroneTravelStats
local function updateStatisticsForAll(struct, stats)
	for _,p in pairs(game.players) do
		local data = getGui(p)
		if data and data.struct == struct then
			updateStatistics(p, stats)
		end
	end
end

---@param player LuaPlayer
local function closeGui(player)
	local data = getGui(player)
	if not data then return end
	if player.opened == data.components.container then
		player.opened = nil
	end
end

---@param player LuaPlayer
local function checkRangeForTabs(player)
	local data = getGui(player)
	if not data then return end

	local tabs = data.components.tabs.tabs
	local entities = {
		data.struct.base,
		data.struct.fuel,
		data.struct.export,
		data.struct.import
	}
	for i,obj in pairs(entities) do
		local reach = player.can_reach_entity(obj)
		if i == 1 and not reach then
			closeGui(player)
			return
		end
		local tab = tabs[i].tab
		tab.enabled = reach
		tab.tooltip = reach and "" or {"cant-reach"}
	end
end

---@param event on_gui_closed
local function onGuiClosed(event)
	if event.gui_type ~= defines.gui_type.custom then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	if event.element == data.components.container then
		data.port = nil
		data.components.container.visible = false
	end
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not (data and data.struct) then return end
	local components = data.components

	if event.element == components.close then
		closeGui(player)

	elseif event.element == components.rename.button then
		components.rename.name_flow.visible = false
		components.rename.flow.visible = true
		components.rename.input.text = data.struct.name
		components.rename.input.focus()

	elseif event.element == components.rename.confirm then
		local newname = components.rename.input.text
		if newname ~= "" then
			callbacks.rename(player, data.struct, newname)
		end
		components.rename.flow.visible = false
		components.rename.name_flow.visible = true

	elseif event.element == components.rename.cancel then
		components.rename.flow.visible = false
		components.rename.name_flow.visible = true

	elseif event.element == components.destination.select then
		components.destination.search_flow.visible = not components.destination.search_flow.visible
		components.stats.table.visible = not components.destination.search_flow.visible

	elseif event.element == components.destination.map then
		callbacks.map_destination(player, data.struct)
		closeGui(player)

	elseif event.element == components.minimap.map then
		callbacks.map_drone(player, data.struct)
		closeGui(player)
	end
end

---@param event on_gui_confirmed
local function onGuiConfirm(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not (data and data.struct) then return end
	local components = data.components

	if event.element == components.rename.input then
		local newname = components.rename.input.text
		if newname ~= "" then
			callbacks.rename(player, data.struct, newname)
		end
		components.rename.flow.visible = false
		components.rename.name_flow.visible = true

	elseif event.element == components.destination.search_input then
		local first_result = components.destination.search_results.tags['search-ids'][1]
		if first_result then
			callbacks.set_destination(player, data.struct, first_result)
			components.destination.search_flow.visible = false
			components.stats.table.visible = true
		end
	end
end

---@param event on_gui_text_changed
local function onGuiTextChange(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not (data and data.struct) then return end
	local components = data.components

	if event.element == components.destination.search_input then
		local results = callbacks.search(player, data.struct, components.destination.search_input.text)
		local list = components.destination.search_results
		list.clear_items()
		local ids = {}
		for _,struct in pairs(results) do
			table.insert(ids, struct.base.unit_number)
			list.add_item(struct.name)
		end
		list.tags = {['search-ids'] = ids}
	end
end

---@param event on_gui_selection_state_changed
local function onGuiSelectionChange(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not (data and data.struct) then return end
	local components = data.components

	if event.element == components.destination.search_results then
		local results = components.destination.search_results
		local selected = results.tags['search-ids'][results.selected_index]
		callbacks.set_destination(player, data.struct, selected)
	end
end

---@param event on_gui_selected_tab_changed
local function onGuiTabChange(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not (data and data.struct) then return end
	local components = data.components

	if event.element == components.tabs then
		local entities = {
			data.struct.base,
			data.struct.fuel,
			data.struct.export,
			data.struct.import
		}
		player.opened = entities[components.tabs.selected_tab_index]
	end
end

-- if a player had a port's GUI open, close it
---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	for _,player in pairs(game.players) do
		local data = getGui(player)
		if data and data.struct and data.struct.base == entity then
			closeGui(player)
		end
	end
end

-- if the player moves and has a port open, update tab availability
---@param event on_player_changed_position
local function onMove(event)
	local player = game.players[event.player_index]
	checkRangeForTabs(player)
end

return {
	open_gui = openGui,
	update = {
		name = updateNameForAll,
		status = updateStatusForAll,
		minimap = updateMinimapForAll,
		destination = updateDestinationForAll,
		statistics = updateStatisticsForAll
	},
	callbacks = callbacks,
	lib = bev.applyBuildEvents{
		on_init = function()
			global.gui.drone_port = global.gui.drone_port or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.drone_port or script_data
		end,
		on_destroy = onRemoved,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick,
			[defines.events.on_gui_confirmed] = onGuiConfirm,
			[defines.events.on_gui_text_changed] = onGuiTextChange,
			[defines.events.on_gui_selection_state_changed] = onGuiSelectionChange,
			[defines.events.on_gui_selected_tab_changed] = onGuiTabChange,
			[defines.events.on_player_changed_position] = onMove
		}
	}
}
