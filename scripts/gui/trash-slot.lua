---@class TrashSlotGui
---@field player LuaPlayer
---@field components TrashSlotGuiComponents

---@class TrashSlotGuiComponents
---@field frame LuaGuiElement
---@field slot LuaGuiElement

---@alias global.gui.trash_slot table<uint, TrashSlotGui>
---@type global.gui.trash_slot
local script_data = {}

---@class TrashSlotGuiCallbacks
---@field trash fun(player:LuaPlayer, stack:LuaItemStack, event:on_gui_click)
local callbacks = {
	trash = function() end
}

---@param player LuaPlayer
---@return TrashSlotGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return TrashSlotGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = gui.add{
		type = "frame",
		anchor = {
			gui = defines.relative_gui_type.controller_gui,
			position = defines.relative_gui_position.bottom
		},
		style = "frame_with_even_paddings"
	}
	local slot = frame.add{
		type = "sprite-button",
		style = "slot",
		sprite = "utility/trash_white",
		tooltip = {"gui.trash-slot-tooltip"}
	}
	-- ensure icon is a reasonable size inside the slot
	slot.style.padding = 6

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			slot = slot
		}
	}
	return script_data[player.index]
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.slot then
		if player.cursor_stack.valid_for_read then
			callbacks.trash(player, player.cursor_stack, event)
		end
	end
end

return {
	create_gui = createGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.trash_slot = global.gui.trash_slot or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.trash_slot or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
