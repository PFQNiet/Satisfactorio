---@class PowerStorageGui
---@field player LuaPlayer
---@field battery LuaEntity
---@field components PowerStorageGuiComponents

---@class PowerStorageGuiComponents
---@field frame LuaGuiElement
---@field label LuaGuiElement
---@field bar LuaGuiElement

---@alias global.gui.power_storage table<uint, PowerStorageGui>
---@type global.gui.power_storage
local script_data = {}

---@param player LuaPlayer
---@return PowerStorageGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return PowerStorageGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = gui.add{
		type = "frame",
		anchor = {
			gui = defines.relative_gui_type.accumulator_gui,
			position = defines.relative_gui_position.bottom,
			name = "power-storage"
		},
		direction = "vertical",
		style = "frame_with_even_paddings"
	}

	local inner = frame.add{
		type = "frame",
		direction = "vertical",
		style = "inside_shallow_frame_with_padding_and_spacing"
	}
	inner.add{
		type = "label",
		caption = {"gui.battery-flow-title"},
		style = "caption_label"
	}
	local flow = inner.add{
		type = "flow",
		direction = "horizontal",
		style = "horizontal_flow_with_extra_spacing"
	}
	flow.add{
		type = "sprite-button",
		sprite = "item/train-power",
		style = "transparent_slot"
	}
	local flow2 = flow.add{
		type = "flow",
		direction = "vertical"
	}
	local label = flow2.add{
		type = "label",
		caption = {"gui.battery-flow-calculating"}
	}
	local bar = flow2.add{
		type = "progressbar",
		style = "stretched_progressbar"
	}

	script_data[player.index] = {
		player = player,
		battery = nil,
		components = {
			frame = frame,
			label = label,
			bar = bar
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param battery LuaEntity
local function openGui(player, battery)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.battery = battery
	data.components.label.caption = {"gui.battery-flow-calculating"}
end

---@param player LuaPlayer
---@param flow number
---@param capacity number
local function updateFlow(player, flow, capacity)
	local data = getGui(player)
	local colours = {
		["red"] = {218,69,53},
		["green"] = {43,227,39}
	}
	local colour = colours[flow < 0 and "red" or "green"]
	local caption
	if flow == 0 then
		caption = data.battery.energy > 0 and {"gui.battery-flow-full"} or {"gui.battery-flow-empty"}
	else
		local time = flow > 0 and math.ceil((capacity - data.battery.energy) / flow) or math.ceil(data.battery.energy / -flow)
		caption = {
			"gui.battery-flow-charge",
			("%.1f"):format(math.abs(flow)/1000000),
			math.floor(time/3600),
			math.floor(time/60)%60 < 10 and "0" or "",
			math.floor(time/60)%60,
			time%60 < 10 and "0" or "",
			time%60
		}
	end

	data.components.label.caption = caption
	data.components.bar.style.color = colour
	data.components.bar.value = data.battery.energy / capacity
end

return {
	open_gui = openGui,
	update_flow = updateFlow,
	lib = {
		on_init = function()
			global.gui.power_storage = global.gui.power_storage or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.power_storage or script_data
		end
	}
}
