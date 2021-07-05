---@class SmartSplitterData
---@field base LuaEntity ConstantCombinator
---@field buffer LuaEntity Container
---@field filters table<string, string|string[]|nil> Names of one or more items or any/any-undefined/overflow to allow through the given direction
---@field connections table<string, MachineConnection>

---@class global.splitters
---@field splitters table<uint, SmartSplitterData> Map of splitter unit number to data
---@field gui table<uint, SmartSplitterData> Map of player ID to opened splitter data
local script_data = {
	splitters = {},
	gui = {}
}

return {
	on_init = function()
		global.splitters = global.splitters or script_data
	end,
	on_load = function()
		script_data.splitters = (global.splitters or script_data).splitters
		script_data.gui = (global.splitters or script_data).gui
	end,

	data = script_data
}
