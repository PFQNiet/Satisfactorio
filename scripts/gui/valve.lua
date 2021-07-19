---@class ValveGui
---@field player LuaPlayer
---@field valve ValveData
---@field components ValveGuiComponents

---@class ValveGuiComponents
---@field frame LuaGuiElement
---@field slider LuaGuiElement
---@field input LuaGuiElement
---@field maxlabel LuaGuiElement

---@alias global.gui.valve table<uint, ValveGui>
---@type global.gui.valve
local script_data = {}

---@class ValveGuiCallbacks
---@field set_flow fun(player:LuaPlayer, valve:ValveData, flow:number)
local callbacks = {
	set_flow = function() end
}

---@param player LuaPlayer
---@return ValveGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return ValveGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = gui.add{
		type = "frame",
		anchor = {
			gui = defines.relative_gui_type.constant_combinator_gui,
			position = defines.relative_gui_position.bottom,
			name = "valve"
		},
		direction = "vertical",
		style = "frame_with_even_paddings"
	}

	local content = frame.add{
		type = "frame",
		direction = "vertical",
		style = "inside_shallow_frame_with_padding_and_spacing"
	}
	local sliderbox = content.add{
		type = "flow",
		direction = "horizontal",
		style = "vertically_aligned_flow"
	}
	sliderbox.add{
		type = "label",
		style = "caption_label",
		caption = {"gui.valve-flow-rate-label"}
	}
	local slider = sliderbox.add{
		type = "slider",
		name = "valve-flow-slider",
		style = "stretched_slider",
		minimum_value = 0,
		maximum_value = 300,
		value = 300
	}
	local bottom = content.add{
		type = "flow",
		direction = "horizontal",
		style = "vertically_aligned_flow"
	}
	local input = bottom.add{
		type = "textfield",
		numeric = true,
		allow_decimal = false,
		allow_negative = false,
		lose_focus_on_confirm = true,
		style = "short_number_textfield"
	}
	local max = bottom.add{
		type = "label",
		caption = {"gui.valve-flow-rate-unit-and-max",{"per-minute-suffix"},300}
	}

	script_data[player.index] = {
		player = player,
		valve = nil,
		components = {
			frame = frame,
			slider = slider,
			input = input,
			maxlabel = max
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param valve ValveData
---@param max number Max flow available to the player at this time
local function openGui(player, valve, max)
	local data = getGui(player)
	if not data then data = createGui(player) end

	data.valve = valve
	data.components.slider.set_slider_minimum_maximum(0,max)
	data.components.slider.slider_value = valve.flow
	data.components.input.text = tostring(valve.flow)
	data.components.maxlabel.caption = {"gui.valve-flow-rate-unit-and-max",{"per-minute-suffix"},600}
end

-- update gui for any player with the given valve open
---@param valve ValveData
local function updateGui(valve)
	for _,p in pairs(game.players) do
		if p.opened == valve.base then
			local data = getGui(player)
			data.components.slider.slider_value = valve.flow
			data.components.input.text = tostring(valve.flow)
		end
	end
end

---@param event on_gui_value_changed
local function onGuiValueChanged(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.slider then
		local flow = event.element.slider_value
		callbacks.set_flow(player, data.valve, flow)
		flow = data.valve.flow
		for _,p in pairs(game.players) do
			if p.opened == data.valve.base then
				local other = getGui(p)
				if p ~= player then
					other.components.slider.slider_value = flow
				end
				other.components.input.text = tostring(flow)
			end
		end
	end
end

---@param event on_gui_confirmed
local function onGuiConfirmed(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.input then
		local flow = tonumber(event.element.text)
		callbacks.set_flow(player, data.valve, flow)
		flow = data.valve.flow
		for _,p in pairs(game.players) do
			if p.opened == data.valve.base then
				local other = getGui(p)
				if p ~= player then
					other.components.input.text = tostring(flow)
				end
				other.components.slider.slider_value = flow
			end
		end
	end
end

return {
	open_gui = openGui,
	update_gui = updateGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.valve = global.gui.valve or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.valve or script_data
		end,
		events = {
			[defines.events.on_gui_value_changed] = onGuiValueChanged,
			[defines.events.on_gui_confirmed] = onGuiConfirmed
		}
	}
}
