local script_data = {
	opened = {},
	beacons = {}
}

return {
	on_init = function()
		global.beacons = global.beacons or script_data
	end,
	on_load = function()
		script_data = global.beacons or script_data
	end,
	opened = script_data.opened,
	beacons = script_data.beacons
}
