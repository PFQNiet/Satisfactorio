---@class ElevatorGui
---@field player LuaPlayer
---@field elevator LuaEntity
---@field components ElevatorGuiComponents

---@class ElevatorGuiComponents
---@field flow LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.elevator table<uint, ElevatorGui>
---@type global.gui.elevator
local script_data = {}

---@class ElevatorGuiCallbacks
---@field submit fun(player:LuaPlayer, elevator:LuaEntity)
local callbacks = {
	submit = function() end
}

---@param player LuaPlayer
---@return ElevatorGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return ElevatorGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local flow = gui.add{
		type = "flow",
		anchor = {
			gui = defines.relative_gui_type.assembling_machine_gui,
			position = defines.relative_gui_position.bottom,
			name = "space-elevator"
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
		caption = {"gui.space-elevator-submit-caption"}
	}

	script_data[player.index] = {
		player = player,
		elevator = nil,
		components = {
			flow = flow,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param elevator LuaEntity
local function openGui(player, elevator)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.elevator = elevator
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
		callbacks.submit(player, data.elevator)
	end
end

return {
	open_gui = openGui,
	set_enabled = setEnabled,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.elevator = global.gui.elevator or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.elevator or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
