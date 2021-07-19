---@class AwesomeSinkGui
---@field player LuaPlayer
---@field components AwesomeSinkGuiComponents

---@class AwesomeSinkGuiComponents
---@field frame LuaGuiElement
---@field printable LuaGuiElement
---@field tonext LuaGuiElement
---@field perminute LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.awesome_sink table<uint, AwesomeSinkGui>
---@type global.gui.awesome_sink
local script_data = {}

---@class AwesomeSinkGuiCallbacks
---@field print fun(player:LuaPlayer)
local callbacks = {
	print = function() end
}

---@param player LuaPlayer
---@return AwesomeSinkGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return AwesomeSinkGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = gui.add{
		type = "frame",
		anchor = {
			gui = defines.relative_gui_type.furnace_gui,
			position = defines.relative_gui_position.right,
			name = "awesome-sink"
		},
		direction = "vertical",
		caption = {"gui.awesome-sink-gui-title"}
	}
	local inner = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding_and_spacing",
		direction = "vertical"
	}
	local table = inner.add{
		type = "table",
		style = "awesome_sink_table",
		column_count = 2
	}
	table.add{
		type = "label",
		caption = {"gui.awesome-sink-printable-coupons"},
		style = "bold_label"
	}
	local printable = table.add{
		type = "label",
		caption = "0"
	}

	table.add{
		type = "label",
		caption = {"gui.awesome-sink-gain"}
	}
	local perminute = table.add{
		type = "label",
		caption = "0"
	}

	table.add{
		type = "label",
		caption = {"gui.awesome-sink-to-next"}
	}
	local tonext = table.add{
		type = "label",
		name = "tonext",
		caption = "0"
	}

	local bottom = inner.add{
		type = "flow",
		name = "bottom"
	}
	bottom.add{type="empty-widget", style="filler_widget"}
	local button = bottom.add{
		type = "button",
		style = "submit_button",
		caption = {"gui.awesome-sink-print"}
	}
	button.enabled = false

	inner.add{
		type = "empty-widget",
		style = "vertical_lines_slots_filler"
	}

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			printable = printable,
			tonext = tonext,
			perminute = perminute,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param sink AwesomeSinkData
local function updateGui(player, sink)
	local data = getGui(player)
	if not data then return end

	local components = data.components

	components.printable.caption = util.format_number(sink.tickets.earned - sink.tickets.printed)
	components.perminute.caption = util.format_number(sink.points.per_minute)
	components.tonext.caption = util.format_number(sink.tonext - sink.points.earned)
	components.button.enabled = sink.tickets.earned > sink.tickets.printed
end

---@param force LuaForce
---@param sink AwesomeSinkData
local function updateAllGui(force, sink)
	for _,p in pairs(force.players) do
		updateGui(p, sink)
	end
end

---@param player LuaPlayer
---@param sink AwesomeSinkData
local function openGui(player, sink)
	local data = getGui(player)
	if not data then data = createGui(player) end
	local components = data.components

	updateGui(player, sink)
	components.frame.visible = true
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.button then
		callbacks.print(player)
	end
end

return {
	open_gui = openGui,
	update_gui = updateAllGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.awesome_sink = global.gui.awesome_sink or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.awesome_sink or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
