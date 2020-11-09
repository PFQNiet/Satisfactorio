-- uses global.splitter.splitters to track structures {base, buffer, filters, {left1, left2}, {middle1, middle2}, {right1, right2}}
-- GUI uses global.splitter.gui to track player > opened smart splitter
local script_data = {
	splitters = {},
	gui = {}
}

return {
	on_init = function()
		global.splitters = global.splitters or script_data
	end,
	on_load = function()
		script_data = global.splitters or script_data
	end,
	on_configuration_changed = function()
		if not global.splitters then
			global.splitters = script_data
		end
		if global['smart-splitters'] then
			global.splitters.splitters = table.deepcopy(global['smart-splitters'])
			global['smart-splitters'] = nil
		end
		if global['gui-splitter'] then
			global.splitters.gui = table.deepcopy(global['gui-splitter'])
			global['gui-splitter'] = nil
		end
	end,

	splitters = script_data.splitters,
	gui = script_data.gui
}