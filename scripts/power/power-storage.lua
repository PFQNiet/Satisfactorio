local gui = require(modpath.."scripts.gui.power-storage")

-- opening a battery's GUI adds it to the tracking list, closing it (provided no other player has it open) removes it

---@class PowerStorageData
---@field entity LuaEntity
---@field energy_last_tick number
---@field capacity number
---@field opened_by table<uint, boolean> Map of players who have this battery open
---@field rolling_average number

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
				energy_last_tick = nil,
				capacity = event.entity.prototype.electric_energy_source_prototype.buffer_capacity,
				opened_by = {},
				rolling_average = nil
			}
		end
		local player = game.players[event.player_index]
		gui.open_gui(player, event.entity)
		script_data[event.entity.unit_number].opened_by[player.index] = true
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
			if struct.energy_last_tick then
				local flow = energy - struct.energy_last_tick
				struct.rolling_average = ((struct.rolling_average or flow) * 299 + flow) / 300
				for pid in pairs(struct.opened_by) do
					gui.update_flow(game.players[pid], struct.rolling_average * 60, struct.capacity)
				end
			end
			struct.energy_last_tick = energy
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
