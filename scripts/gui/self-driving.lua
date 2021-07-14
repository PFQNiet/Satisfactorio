---@class SelfDrivingGui
---@field player LuaPlayer
---@field vehicle SelfDrivingCarData
---@field components SelfDrivingGuiComponents
---@field editor SelfDrivingGuiEditor

---@class SelfDrivingGuiComponents
---@field frame LuaGuiElement
---@field toggle LuaGuiElement
---@field record LuaGuiElement
---@field list LuaGuiElement

---@class SelfDrivingGuiEditor
---@field editor LuaGuiElement
---@field name LuaGuiElement
---@field time LuaGuiElement
---@field add LuaGuiElement

---@alias global.gui.self_driving table<uint, SelfDrivingGui>
---@type global.gui.self_driving
local script_data = {}

---@class SelfDrivingGuiCallbacks
---@field toggle_recording fun(player:LuaPlayer, car:SelfDrivingCarData)
---@field toggle_autopilot fun(player:LuaPlayer, car:SelfDrivingCarData, on:boolean)
---@field add_waypoint fun(player:LuaPlayer, car:SelfDrivingCarData, name:string, wait:number)
local callbacks = {
	toggle_recording = function() end,
	toggle_autopilot = function() end,
	add_waypoint = function() end
}

---@param player LuaPlayer
---@return SelfDrivingGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return SelfDrivingGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = gui.add{
		type = "frame",
		anchor = {
			gui = defines.relative_gui_type.car_gui,
			position = defines.relative_gui_position.right,
			names = {"truck", "tractor", "explorer"}
		},
		direction = "vertical",
		caption = {"gui.self-driving-title"}
	}

	local inner = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding_and_spacing",
		direction = "vertical"
	}

	local top = inner.add{
		type = "flow",
		direction = "horizontal",
		style = "vertically_aligned_flow"
	}
	local mode_toggle = top.add{
		type = "switch",
		left_label_caption = {"gui.self-driving-mode-manual"},
		right_label_caption = {"gui.self-driving-mode-auto"}
	}
	top.add{type="empty-widget", style="filler_widget"}
	local record_button = top.add{
		type = "button",
		caption = {"gui.self-driving-record"}
	}

	local waypoint_list = inner.add{
		type = "list-box",
		style = "self_driving_list_box"
	}

	local editor = inner.add{
		type = "flow",
		style = "vertical_flow_with_extra_spacing",
		direction = "vertical"
	}

	local name = editor.add{
		type = "flow",
		direction = "horizontal",
		style = "vertically_aligned_flow"
	}
	name.add{
		type = "label",
		caption = {"gui.self-driving-waypoint-name"}
	}
	local name_input = name.add{
		type = "textfield"
	}

	local time = editor.add{
		type = "flow",
		direction = "horizontal",
		style = "vertically_aligned_flow"
	}
	time.add{
		type = "label",
		caption = {"gui.self-driving-waypoint-wait"}
	}
	local time_input = time.add{
		type = "textfield",
		numeric = true,
		text = "25",
		allow_decimal = false,
		allow_negative = false,
		style = "short_number_textfield"
	}
	time.add{
		type = "label",
		caption = {"gui.self-driving-waypoint-seconds"}
	}

	time.add{type="empty-widget", style="filler_widget"}
	local add_button = time.add{
		type = "button",
		style = "green_button",
		caption = {"gui.self-driving-waypoint-add"}
	}

	inner.add{
		type = "empty-widget",
		style = "vertical_lines_slots_filler"
	}

	script_data[player.index] = {
		player = player,
		vehicle = nil,
		components = {
			frame = frame,
			toggle = mode_toggle,
			record = record_button,
			list = waypoint_list
		},
		editor = {
			editor = editor,
			name = name_input,
			time = time_input,
			add = add_button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
local function refreshStopList(player)
	local data = getGui(player)
	local car = data.vehicle
	local menu = data.components.list

	menu.clear_items()
	if #car.waypoints == 0 then return end

	-- which stop is bring driven to next
	local next_stop = 0
	for i=car.waypoint_index-1,#car.waypoints do
		if i < 1 then i = #car.waypoints end
		if car.waypoints[i].wait > 0 then
			next_stop = i
			break
		end
	end

	local index = 0
	local first_stop = true
	for i,waypoint in pairs(car.waypoints) do
		if waypoint.wait > 0 then
			index = index + 1
			local is_target = next_stop == 0 and first_stop or (next_stop == i)
			menu.add_item({"",
				is_target and "▶ " or "",
				(waypoint.name and waypoint.name ~= "") and waypoint.name or {"gui.self-driving-waypoint",index},
				" [img=quantity-time]", {"time-symbol-seconds",waypoint.wait}
			})
			if is_target then
				first_stop = false
				menu.selected_index = index
			end
		end
	end
end

---@param player LuaPlayer
local function updateGui(player)
	local data = getGui(player)
	if not data then return end
	local car = data.vehicle

	local components = data.components
	local editor = data.editor

	components.toggle.switch_state = car.autopilot and "right" or "left"
	refreshStopList(player)

	local rec = components.record
	local driving = player.vehicle == car.car
	if not driving then
		rec.enabled = false
		rec.tooltip = {"gui.self-driving-recording-drive-car"}
	elseif car.autopilot then
		rec.enabled = false
		rec.tooltip = {"gui.self-driving-recording-disable-autopilot"}
	else
		rec.enabled = true
		rec.tooltip = ""
	end

	if car.recording then
		components.toggle.enabled = false
		components.record.caption = {"gui.self-driving-stop"}
		editor.editor.visible = true
	else
		components.toggle.enabled = true
		components.record.caption = {"gui.self-driving-record"}
		editor.editor.visible = false
	end
end

---@param player LuaPlayer
---@param vehicle SelfDrivingCarData
local function openGui(player, vehicle)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.vehicle = vehicle
	updateGui(player)
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components
	local editor = data.editor

	if event.element == components.record then
		callbacks.toggle_recording(player, data.vehicle)
		updateGui(player)

	elseif event.element == editor.add then
		callbacks.add_waypoint(player, data.vehicle, editor.name.text, tonumber(editor.time.text))
		editor.name.text = ""
		updateGui(player)
	end
end

---@param event on_gui_switch_state_changed
local function onGuiSwitch(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.toggle then
		callbacks.toggle_autopilot(player, data.vehicle, components.toggle.switch_state == "right")
		updateGui(player)
	end
end

return {
	open_gui = openGui,
	update_gui = updateGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.self_driving = global.gui.self_driving or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.self_driving or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick,
			[defines.events.on_gui_switch_state_changed] = onGuiSwitch
		}
	}
}
