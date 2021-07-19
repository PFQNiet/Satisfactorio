---@class DronePortTabsGui
---@field player LuaPlayer
---@field entities LuaEntity[]
---@field components DronePortTabsGuiComponents

---@class DronePortTabsGuiComponents
---@field tabs LuaGuiElement

---@alias global.gui.drone_port_tabs table<uint, DronePortTabsGui>
---@type global.gui.drone_port_tabs
local script_data = {}

---@param player LuaPlayer
---@return DronePortTabsGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return DronePortTabsGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local tabs = gui.add{
		type = "tabbed-pane",
		anchor = {
			gui = defines.relative_gui_type.container_gui,
			position = defines.relative_gui_position.top,
			names = {"drone-port-box", "drone-port-fuelbox"}
		},
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

	script_data[player.index] = {
		player = player,
		entities = {},
		components = {
			tabs = tabs
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
local function checkRangeForTabs(player)
	local data = getGui(player)
	if not data then return end

	local tabs = data.components.tabs.tabs
	for i,obj in pairs(data.entities) do
		local reach = player.can_reach_entity(obj)
		local tab = tabs[i].tab
		tab.enabled = reach
		tab.tooltip = reach and "" or {"cant-reach"}
	end
end

---@param player LuaPlayer
---@param port LuaEntity
---@param fuelbox LuaEntity
---@param export LuaEntity
---@param import LuaEntity
local function openGui(player, port, fuelbox, export, import)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.entities = {port, fuelbox, export, import}
	for i,obj in pairs(data.entities) do
		if player.opened == obj then
			data.components.tabs.selected_tab_index = i
		end
	end
	checkRangeForTabs(player)
end

---@param event on_gui_selected_tab_changed
local function onGuiTabChange(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.tabs then
		player.opened = data.entities[event.element.selected_tab_index]
	end
end

-- update tab enabled state based on reach
---@param event on_player_changed_position
local function onMove(event)
	local player = game.players[event.player_index]
	checkRangeForTabs(player)
end

return {
	open_gui = openGui,
	lib = {
		on_init = function()
			global.gui.drone_port_tabs = global.gui.drone_port_tabs or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.drone_port_tabs or script_data
		end,
		events = {
			[defines.events.on_gui_selected_tab_changed] = onGuiTabChange,
			[defines.events.on_player_changed_position] = onMove
		}
	}
}
