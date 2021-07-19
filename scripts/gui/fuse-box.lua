---@class FuseBoxGui
---@field player LuaPlayer
---@field generator LuaEntity
---@field components FuseBoxGuiComponents

---@class FuseBoxGuiComponents
---@field flow LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.fuse_box table<uint, FuseBoxGui>
---@type global.gui.fuse_box
local script_data = {}

---@class FuseBoxGuiCallbacks
---@field reset fun(player:LuaPlayer, generator:LuaEntity)
local callbacks = {
	reset = function() end
}

---@param player LuaPlayer
---@return FuseBoxGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return FuseBoxGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local flow = gui.add{
		type = "flow",
		anchor = {
			gui = defines.relative_gui_type.entity_with_energy_source_gui,
			position = defines.relative_gui_position.bottom
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
		caption = {"gui.power-trip-reset-fuse-button"}
	}

	script_data[player.index] = {
		player = player,
		generator = nil,
		components = {
			flow = flow,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param generator LuaEntity
local function openGui(player, generator)
	local data = getGui(player)
	if not data then data = createGui(player) end

	-- update anchor based on generator type
	local types = {
		["burner-generator"] = "entity_with_energy_source_gui",
		["electric-energy-interface"] = "electric_energy_interface_gui",
		["furnace"] = "furnace_gui",
		["default"] = "assembling_machine_gui"
	}
	local flow = data.components.flow
	flow.anchor = {
		gui = defines.relative_gui_type[types[generator.type] or types["default"]],
		position = defines.relative_gui_position.bottom,
		name = generator.name
	}
	flow.visible = true

	data.generator = generator
end

---@param player LuaPlayer
local function closeGui(player)
	local data = getGui(player)
	if not data then return end
	data.components.flow.visible = false
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.button then
		callbacks.reset(player, data.generator)
	end
end

return {
	open_gui = openGui,
	close_gui = closeGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.fuse_box = global.gui.fuse_box or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.fuse_box or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
