local consts = require(modpath.."scripts.lualib.splitters")

---@class SmartSplitterGui
---@field player LuaPlayer
---@field struct SmartSplitterData
---@field components SmartSplitterGuiComponents

---@class SmartSplitterGuiComponents
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field columns table<SmartSplitterDirection, SmartSplitterGuiColumn>

---@class SmartSplitterGuiColumn
---@field frame LuaGuiElement
---@field dropdown LuaGuiElement
---@field item LuaGuiElement

---@alias global.gui.smart_splitter table<uint, SmartSplitterGui>
---@type global.gui.smart_splitter
local script_data = {}

---@class SmartSplitterGuiCallbacks
---@field update fun(player:LuaPlayer, struct:SmartSplitterData)
local callbacks = {
	update = function() end
}

---@param player LuaPlayer
---@return SmartSplitterGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return SmartSplitterGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		direction = "vertical"
	}
	local title_flow = frame.add{type = "flow"}
	local title = title_flow.add{type = "label", caption = game.entity_prototypes['smart-splitter'].localised_name, style = "frame_title"}
	title.drag_target = frame
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = frame
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white"}

	local columns = frame.add{
		type = "flow",
		style = "horizontal_flow_with_extra_spacing"
	}
	local cols = {}
	for dir in pairs(consts.directions) do
		local col = columns.add{
			type = "frame",
			style = "inside_shallow_frame",
			direction = "vertical"
		}
		local subtitle = col.add{
			type = "frame",
			style = "full_subheader_frame"
		}
		subtitle.add{
			type = "label",
			style = "heading_2_label",
			caption = {"gui.smart-splitter-"..dir}
		}
		local list = col.add{
			type = "flow",
			style = "smart_splitter_filter_container_flow",
			direction = "vertical"
		}

		local flow = list.add{
			type = "flow",
			style = "smart_splitter_filter_flow"
		}
		local menu = flow.add{
			type = "drop-down",
			name = "smart-splitter-filter-menu",
			tags = {direction = dir},
			style = "smart_splitter_filter_dropdown",
			items = {
				"None",
				{"","[img=virtual-signal.signal-any] ",{"gui.smart-splitter-any"}},
				{"","[img=virtual-signal.signal-any-undefined] ",{"gui.smart-splitter-any-undefined"}},
				{"","[img=virtual-signal.signal-overflow] ",{"gui.smart-splitter-overflow"}},
				"Item..."
			},
			selected_index = 1
		}
		local item = flow.add{
			type = "choose-elem-button",
			name = "smart-splitter-filter-item",
			tags = {direction = dir},
			elem_type = "item"
		}
		item.visible = false

		cols[dir] = {
			frame = col,
			dropdown = menu,
			item = item
		}
	end

	script_data[player.index] = {
		player = player,
		struct = nil,
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
	---@type table<SmartSplitterDirection, SmartSplitterFilterSingle>
	local filters = data.struct.filters

	for dir in pairs(consts.directions) do
		local col = columns[dir]
		local filter = filters[dir]
		local menu = col.dropdown
		local item = col.item

		item.visible = false
		if not filter then menu.selected_index = 1
		elseif filter == consts.specials.any then menu.selected_index = 2
		elseif filter == consts.specials["any-undefined"] then menu.selected_index = 3
		elseif filter == consts.specials.overflow then menu.selected_index = 4
		else
			menu.selected_index = 5
			item.elem_value = filter
			item.visible = true
		end
	end
end

-- refresh GUI for all players with this struct open
---@param struct SmartSplitterData
local function updateAllGui(struct)
	for _,p in pairs(game.players) do
		local data = getGui(p)
		if data and data.struct == struct then
			updateGui(p)
		end
	end
end

---@param player LuaPlayer
---@param struct SmartSplitterData
---@return SmartSplitterGui
local function openGui(player, struct)
	local data = getGui(player)
	if not data then data = createGui(player) end
	data.struct = struct

	updateGui(player)

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

---@param struct SmartSplitterData
local function closeAllGui(struct)
	for _,p in pairs(game.players) do
		if p.opened_gui_type == defines.gui_type.custom then
			local data = getGui(p)
			if data and p.opened == data.components.frame then
				closeGui(p)
			end
		end
	end
end

---@param event on_gui_closed
local function onGuiClosed(event)
	if event.gui_type ~= defines.gui_type.custom then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	if event.element == data.components.frame then
		data.struct = nil
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
end

---@param event on_gui_selection_state_changed
local function onGuiSelected(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element.name == "smart-splitter-filter-menu" then
		---@type SmartSplitterDirection
		local dir = event.element.tags['direction']
		local col = components.columns[dir]
		---@type SmartSplitterFilterSingle[]
		local options = {
			nil,
			consts.specials.any,
			consts.specials["any-undefined"],
			consts.specials.overflow,
			col.item.elem_value
		}
		data.struct.filters[dir] = options[col.dropdown.selected_index]
		callbacks.update(player, data.struct)

		col.item.visible = col.dropdown.selected_index == 5

		-- propagate change to other players with this GUI open
		for _,p in pairs(game.players) do
			if p ~= player then
				local other = getGui(p)
				if other.struct == data.struct then
					updateGui(p)
				end
			end
		end
	end
end

---@param event on_gui_elem_changed
local function onGuiElemChanged(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element.name == "smart-splitter-filter-item" then
		---@type SmartSplitterDirection
		local dir = event.element.tags['direction']
		local col = components.columns[dir]
		data.struct.filters[dir] = col.item.elem_value
		callbacks.update(player, data.struct)

		col.dropdown.selected_index = 5

		-- propagate change to other players with this GUI open
		for _,p in pairs(game.players) do
			if p ~= player then
				local other = getGui(p)
				if other.struct == data.struct then
					updateGui(p)
				end
			end
		end
	end
end

-- if the player moves and has a pet open, check that the pet can still be reached
---@param event on_player_changed_position
local function onMove(event)
	local player = game.players[event.player_index]
	local data = getGui(player)
	if data and data.struct then
		local base = data.struct.base
		if not (base.valid and player.can_reach_entity(base)) then
			closeGui(player)
		end
	end
end

return {
	open_gui = openGui,
	update_gui = updateAllGui,
	destroy_gui = closeAllGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.smart_splitter = global.gui.smart_splitter or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.smart_splitter or script_data
		end,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick,
			[defines.events.on_gui_selection_state_changed] = onGuiSelected,
			[defines.events.on_gui_elem_changed] = onGuiElemChanged,
			[defines.events.on_player_changed_position] = onMove
		}
	}
}
