local script_data = {
	opened = {},
	beacons = {}
}

return {
	on_init = function()
		global.beacons = global.beacons or script_data
	end,
	on_load = function()
		script_data.opened = (global.beacons or script_data).opened
		script_data.beacons = (global.beacons or script_data).beacons
	end,

	data = script_data
}
