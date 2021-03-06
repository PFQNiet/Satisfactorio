-- opening a battery's GUI adds it to the tracking list, closing it (provided no other player has it open) removes it

---@class PowerStorageData
---@field entity LuaEntity
---@field energy_last_tick number
---@field capacity number
---@field opened_by table<uint, LuaGuiElement> Map player ID to the GUI element
---@field rolling_average number[]

---@alias global.battery_flow table<uint, PowerStorageData>
---@type global.battery_flow
local script_data = {}

local battery = "power-storage"

---@param event on_gui_opened
local function onGuiOpened(event)
	if not (event.entity and event.entity.valid) then return end
	if event.entity.name == battery then
		if not script_data[event.entity.unit_number] then
			script_data[event.entity.unit_number] = {
				entity = event.entity,
				energy_last_tick = event.entity.energy,
				capacity = event.entity.prototype.electric_energy_source_prototype.buffer_capacity,
				opened_by = {},
				rolling_average = {}
			}
		end
		local player = game.players[event.player_index]
		local gui = player.gui.relative
		if not gui['battery-flow'] then
			local frame = player.gui.relative.add{
				type = "frame",
				name = "battery-flow",
				anchor = {
					gui = defines.relative_gui_type.accumulator_gui,
					position = defines.relative_gui_position.bottom,
					name = battery
				},
				direction = "vertical",
				style = "frame_with_even_paddings"
			}

			local inner = frame.add{
				type = "frame",
				name = "inner",
				direction = "vertical",
				style = "inside_shallow_frame_with_padding_and_spacing"
			}
			inner.add{
				type = "label",
				caption = {"gui.battery-flow-title"},
				style = "heading_3_label"
			}
			local flow = inner.add{
				type = "flow",
				direction = "horizontal",
				name = "content",
				style = "horizontal_flow_with_extra_spacing"
			}
			flow.add{
				type = "sprite-button",
				sprite = "recipe/coal-generator-steam",
				style = "transparent_slot"
			}
			local flow2 = flow.add{
				type = "flow",
				direction = "vertical",
				name = "details"
			}
			flow2.add{
				type = "label",
				caption = {"gui.battery-flow-calculating"},
				name = "flowtext"
			}
			local bar = flow2.add{
				type = "progressbar",
				style = "stretched_progressbar",
				name = "bar"
			}
		end

		script_data[event.entity.unit_number].opened_by[player.index] = gui['battery-flow'].inner.content.details
	end
end
---@param event on_gui_closed
local function onGuiClosed(event)
	if not (event.entity and event.entity.valid) then return end
	if event.entity.name == battery and script_data[event.entity.unit_number] then
		local player = game.players[event.player_index]
		local struct = script_data[event.entity.unit_number]
		struct.opened_by[player.index] = nil
		if not next(struct.opened_by) then
			script_data[event.entity.unit_number] = nil
		end
	end
end

local function onTick()
	for id,struct in pairs(script_data) do
		if not struct.entity.valid then
			script_data[id] = nil
		else
			local energy = struct.entity.energy
			local bar = energy / struct.capacity
			local caption = {"gui.battery-flow-calculating"}
			local colours = {
				["red"] = {218,69,53},
				["green"] = {43,227,39}
			}
			local colour = "green"
			table.insert(struct.rolling_average, energy - struct.energy_last_tick)
			struct.energy_last_tick = energy
			if #struct.rolling_average > 60 then
				table.remove(struct.rolling_average,1)
				local avg = 0
				for _,val in pairs(struct.rolling_average) do
					avg = avg + val -- /60 values * 60t/s
				end
				if avg == 0 then
					if energy > 0 then
						caption = {"gui.battery-flow-full"}
					else
						caption = {"gui.battery-flow-empty"}
					end
				elseif avg > 0 then
					local time_to_full = math.ceil((struct.capacity - energy) / avg)
					caption = {
						"gui.battery-flow-charge",
						string.format("%.1f",avg/1000000),
						math.floor(time_to_full/3600),
						math.floor(time_to_full/60)%60 < 10 and "0" or "",
						math.floor(time_to_full/60)%60,
						time_to_full%60 < 10 and "0" or "",
						time_to_full%60
					}
				else
					colour = "red"
					local time_to_empty = math.ceil(energy / -avg)
					caption = {
						"gui.battery-flow-discharge",
						string.format("%.1f",-avg/1000000),
						math.floor(time_to_empty/3600),
						math.floor(time_to_empty/60)%60 < 10 and "0" or "",
						math.floor(time_to_empty/60)%60,
						time_to_empty%60 < 10 and "0" or "",
						time_to_empty%60
					}
				end
			end
			for _,gui in pairs(struct.opened_by) do
				gui['flowtext'].caption = caption
				gui['bar'].value = bar
				gui['bar'].style.color = colours[colour]
			end
		end
	end
end

return {
	on_init = function()
		global.battery_flow = global.battery_flow or script_data
	end,
	on_load = function()
		script_data = global.battery_flow or script_data
	end,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_tick] = onTick
	}
}
