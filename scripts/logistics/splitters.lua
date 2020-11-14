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
		script_data.splitters = (global.splitters or script_data).splitters
		script_data.gui = (global.splitters or script_data).gui
	end,

	data = script_data
}
