---@class HubTerminalGui
---@field player LuaPlayer
---@field terminal LuaEntity
---@field components HubTerminalGuiComponents

---@class HubTerminalGuiComponents
---@field flow LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.hub_terminal table<uint, HubTerminalGui>
---@type global.gui.hub_terminal
local script_data = {}

---@class HubTerminalGuiCallbacks
---@field submit fun(player:LuaPlayer, terminal:LuaEntity)
local callbacks = {
	submit = function() end
}

---@param player LuaPlayer
---@return HubTerminalGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return HubTerminalGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local flow = gui.add{
		type = "flow",
		anchor = {
			gui = defines.relative_gui_type.assembling_machine_gui,
			position = defines.relative_gui_position.bottom,
			name = "the-hub-terminal"
		},
		direction = "horizontal"
	}
	flow.add{type="empty-widget", style="filler_widget"}
	local frame = flow.add{
		type = "frame",
		style = "frame_with_even_paddings"
	}
	local button = frame.add{
		type = "button",
		style = "submit_button",
		caption = {"gui.hub-milestone-submit-caption"}
	}

	script_data[player.index] = {
		player = player,
		terminal = nil,
		components = {
			flow = flow,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param terminal LuaEntity
local function openGui(player, terminal)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.terminal = terminal
	data.components.button.enabled = false
end

---@param player LuaPlayer
---@param enabled boolean
local function setEnabled(player, enabled)
	local data = getGui(player)
	if not data then return end
	data.components.button.enabled = enabled
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.button then
		callbacks.submit(player, data.terminal)
	end
end

return {
	open_gui = openGui,
	set_enabled = setEnabled,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.hub_terminal = global.gui.hub_terminal or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.hub_terminal or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
