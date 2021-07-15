---@class SortContainerGui
---@field player LuaPlayer
---@field container LuaEntity
---@field components SortContainerGuiComponents

---@class SortContainerGuiComponents
---@field flow LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.sort_container table<uint, SortContainerGui>
---@type global.gui.sort_container
local script_data = {}

---@param player LuaPlayer
---@return SortContainerGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return SortContainerGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local flow = gui.add{
		type = "flow",
		anchor = {
			gui = defines.relative_gui_type.container_gui,
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
		style = "dialog_button",
		name = "sort-storage",
		caption = {"gui.sort-storage"}
	}

	script_data[player.index] = {
		player = player,
		container = nil,
		components = {
			flow = flow,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param container LuaEntity
local function openGui(player, container)
	-- update anchor based on container type
	local anchortype
	if container.type == "container" then
		if #container.get_inventory(defines.inventory.chest) > 1 then
			anchortype = defines.relative_gui_type.container_gui
		end
	elseif container.type == "cargo-wagon" then
		anchortype = defines.relative_gui_type.container_gui
	elseif container.type == "car" then
		anchortype = defines.relative_gui_type.car_gui
	end

	if anchortype then
		local data = getGui(player)
		if not data then data = createGui(player) end

		data.components.flow.anchor = {
			gui = anchortype,
			position = defines.relative_gui_position.bottom,
			name = container.name
		}
		data.container = container
	end
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.button then
		data.container.get_output_inventory().sort_and_merge()
	end
end

return {
	open_gui = openGui,
	lib = {
		on_init = function()
			global.gui.sort_container = global.gui.sort_container or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.sort_container or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
