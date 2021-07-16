local bev = require(modpath.."scripts.lualib.build-events")

---@class MapMarkerGui
---@field player LuaPlayer
---@field marker LuaEntity
---@field components MapMarkerGuiComponents

---@class MapMarkerGuiComponents
---@field frame LuaGuiElement
---@field name LuaGuiElement
---@field icon LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.map_marker table<uint, MapMarkerGui>
---@type global.gui.map_marker
local script_data = {}

---@class MapMarkerGuiCallbacks
---@field save fun(player:LuaPlayer, marker:LuaEntity, name:string, icon:SignalID)
local callbacks = {
	scan = function() end
}

---@param player LuaPlayer
---@return MapMarkerGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return MapMarkerGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		direction = "vertical",
		caption = {"gui.beacon-title"},
		style = "frame_with_vertical_spacing"
	}
	local inner = frame.add{
		type = "frame",
		direction = "vertical",
		style = "inside_shallow_frame_with_padding"
	}
	local table = inner.add{
		type = "table",
		column_count = 2
	}
	table.add{
		type = "label",
		caption = {"gui.beacon-name"}
	}
	local name = table.add{
		type = "textfield",
		style = "textbox"
	}
	table.add{
		type = "label",
		caption = {"gui.beacon-icon"}
	}
	local icon = table.add{
		type = "choose-elem-button",
		elem_type = "signal",
		style = "slot_button_in_shallow_frame"
	}
	local bottom = frame.add{
		type = "flow",
		direction = "horizontal"
	}
	bottom.add{type="empty-widget", style="filler_widget"}
	local button = bottom.add{
		type = "button",
		style = "confirm_button",
		caption = {"gui.beacon-confirm"}
	}

	script_data[player.index] = {
		player = player,
		marker = nil,
		components = {
			frame = frame,
			name = name,
			icon = icon,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param marker LuaEntity
---@param tag LuaCustomChartTag
local function openGui(player, marker, tag)
	local data = getGui(player)
	if not data then data = createGui(player) end
	local components = data.components

	local frame = components.frame
	frame.visible = true
	player.opened = frame
	frame.force_auto_center()

	components.name.text = tag.text
	components.icon.elem_value = tag.icon

	data.marker = marker
	return data
end

---@param player LuaPlayer
local function closeGui(player)
	local data = getGui(player)
	if not data then return end
	data.marker = nil
	if player.opened == data.components.frame then
		player.opened = nil
	end
	data.components.frame.visible = false
end

---@param event on_gui_closed
local function onGuiClosed(event)
	local player = game.players[event.player_index]
	local data = getGui(player)
	if data and data.marker then
		callbacks.save(player, data.marker, data.components.name.text, data.components.icon.elem_value)
		closeGui(player)
	end
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not (data and data.marker) then return end
	local components = data.components

	if event.element == components.button then
		callbacks.save(player, data.marker, components.name.text, components.icon.elem_value)
		closeGui(player)
	end
end

-- if a player had a beacon's GUI open, close it
---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	for _,player in pairs(game.players) do
		local data = getGui(player)
		if data and data.marker == entity then
			closeGui(player)
		end
	end
end

-- if the player moves and has a beacon open, check that the pet can still be reached
---@param event on_player_changed_position
local function onMove(event)
	local player = game.players[event.player_index]
	local data = getGui(player)
	if data and data.marker then
		if not (data.marker.valid and player.can_reach_entity(data.marker)) then
			closeGui(player)
		end
	end
end

return {
	open_gui = openGui,
	callbacks = callbacks,
	lib = bev.applyBuildEvents{
		on_init = function()
			global.gui.map_marker = global.gui.map_marker or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.map_marker or script_data
		end,
		on_destroy = onRemoved,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick,
			[defines.events.on_player_changed_position] = onMove
		}
	}
}
