---@class StationModeGui
---@field player LuaPlayer
---@field station LuaEntity
---@field cargo LuaEntity
---@field components StationModeGuiComponents

---@class StationModeGuiComponents
---@field frame LuaGuiElement
---@field load StationModeGuiToggle
---@field unload StationModeGuiToggle

---@class StationModeGuiToggle
---@field button LuaGuiElement
---@field label LuaGuiElement

---@alias global.gui.station_mode table<uint, StationModeGui>
---@type global.gui.station_mode
local script_data = {}

---@class StationModeGuiCallbacks
---@field toggle_truck fun(player:LuaPlayer, station:LuaEntity, mode:"input"|"output")
---@field toggle_train fun(player:LuaPlayer, station:LuaEntity, mode:"input"|"output")
local callbacks = {
	toggle_truck = function() end,
	toggle_train = function() end
}

---@param player LuaPlayer
---@return StationModeGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param entity LuaEntity
---@return GuiAnchor
local function getGuiAnchor(entity)
	return {
		gui = entity.type == "container" and defines.relative_gui_type.container_gui or defines.relative_gui_type.storage_tank_gui,
		position = defines.relative_gui_position.right,
		names = {"truck-station-box", "freight-platform-box", "fluid-freight-platform-tank"}
	}
end

---@param player LuaPlayer
---@return StationModeGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = gui.add{
		type = "frame",
		anchor = getGuiAnchor{type="container"},
		direction = "vertical",
		caption = {"gui.station-gui-title"}
	}
	local inner = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding",
		direction = "vertical"
	}

	local cols = inner.add{
		type = "flow",
		direction = "horizontal",
		style = "horizontal_flow_with_extra_spacing"
	}
	local col = cols.add{
		type = "flow",
		direction = "vertical",
		style = "horizontally_aligned_flow"
	}
	local load_button = col.add{
		type = "sprite-button",
		sprite = "utility/import",
		style = "station_mode_button_pressed"
	}
	local load_label = col.add{
		type = "label",
		caption = {"gui.station-mode-load"},
		style = "caption_label"
	}

	col = cols.add{
		type = "flow",
		direction = "vertical",
		style = "horizontally_aligned_flow"
	}
	local unload_button = col.add{
		type = "sprite-button",
		sprite = "utility/export",
		style = "station_mode_button"
	}
	local unload_label = col.add{
		type = "label",
		caption = {"gui.station-mode-unload"},
		style = "label"
	}

	inner.add{
		type = "empty-widget",
		style = "vertical_lines_slots_filler"
	}

	script_data[player.index] = {
		player = player,
		station = nil,
		components = {
			frame = frame,
			load = {
				button = load_button,
				label = load_label
			},
			unload = {
				button = unload_button,
				label = unload_label
			}
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param mode "input"|"output"
local function setMode(player, mode)
	local data = getGui(player)
	if not data then return end

	data.components.load.button.style = "station_mode_button"..(mode == "input" and "_pressed" or "")
	data.components.load.label.style = (mode == "input" and "caption_" or "").."label"

	data.components.unload.button.style = "station_mode_button"..(mode == "output" and "_pressed" or "")
	data.components.unload.label.style = (mode == "output" and "caption_" or "").."label"
end

---@param player LuaPlayer
---@param station LuaEntity
---@param cargo LuaEntity
---@param mode "input"|"output"
local function openGui(player, station, cargo, mode)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.components.frame.anchor = getGuiAnchor(cargo)

	data.station = station
	data.cargo = cargo
	setMode(player, mode)
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.load.button then
		callbacks.toggle_truck(player, data.station, "input")
		callbacks.toggle_train(player, data.station, "input")
		setMode(player, "input")

	elseif event.element == components.unload.button then
		callbacks.toggle_truck(player, data.station, "output")
		callbacks.toggle_train(player, data.station, "output")
		setMode(player, "output")
	end
end

return {
	open_gui = openGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.station_mode = global.gui.station_mode or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.station_mode or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
