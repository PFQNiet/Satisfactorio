---@class PipeFlowGui
---@field player LuaPlayer
---@field pipe LuaEntity
---@field components PipeFlowGuiComponents

---@class PipeFlowGuiComponents
---@field frame LuaGuiElement
---@field sprite LuaGuiElement
---@field label LuaGuiElement
---@field bar LuaGuiElement
---@field length LuaGuiElement

---@alias global.gui.pipe_flow table<uint, PipeFlowGui>
---@type global.gui.pipe_flow
local script_data = {}

---@param player LuaPlayer
---@return PipeFlowGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return PipeFlowGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = player.gui.relative.add{
		type = "frame",
		anchor = {
			gui = defines.relative_gui_type.pipe_gui,
			position = defines.relative_gui_position.bottom,
			names = {
				"pipeline", "underground-pipeline",
				"pipeline-mk-2", "underground-pipeline-mk-2"
			}
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
		caption = {"gui.pipe-flow-title"},
		style = "caption_label"
	}
	local flow = inner.add{
		type = "flow",
		direction = "horizontal",
		style = "horizontal_flow_with_extra_spacing"
	}
	local sprite = flow.add{
		type = "sprite-button",
		style = "transparent_slot"
	}
	local flow2 = flow.add{
		type = "flow",
		direction = "vertical"
	}
	local label = flow2.add{
		type = "label",
		caption = {"gui.pipe-flow-calculating"}
	}
	local bar = flow2.add{
		type = "progressbar",
		style = "stretched_progressbar"
	}

	local length = inner.add{
		type = "label",
		name = "pipe-length"
	}

	script_data[player.index] = {
		player = player,
		pipe = nil,
		components = {
			frame = frame,
			sprite = sprite,
			label = label,
			bar = bar,
			length = length
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param pipe LuaEntity
---@param length LocalisedString
local function openGui(player, pipe, length)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.pipe = pipe
	data.components.length.caption = length
	data.components.label.caption = {"gui.pipe-flow-calculating"}
end

---@param player LuaPlayer
---@param fluid Fluid
---@param flow number
---@param max number
local function updateFlow(player, fluid, flow, max)
	local data = getGui(player)
	local sprite = "fluid/"..(fluid and fluid.name or "fluid-unknown")
	local name = fluid and game.fluid_prototypes[fluid.name].localised_name or {"gui.pipe-flow-no-fluid"}
	local rate = fluid and ("%.1f"):format(flow) or "---.-"
	local bar = fluid and flow/max or 0
	local caption = {"gui.pipe-flow-details", name, rate, max, {"per-minute-suffix"}}

	data.components.sprite.sprite = sprite
	data.components.label.caption = caption
	data.components.bar.value = bar
end

return {
	open_gui = openGui,
	update_flow = updateFlow,
	lib = {
		on_init = function()
			global.gui.pipe_flow = global.gui.pipe_flow or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.pipe_flow or script_data
		end
	}
}
