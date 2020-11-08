local script_data = {
    opened = {},
    beacons = {}
}

return {
	on_init = function()
		global.beacons = global.becaons or script_data
	end,
	on_load = function()
		script_data = global.beacons or script_data
    end,
    on_configuration_change = function()
        if not global.beacons then
            global.beacons = script_data
        end
        if global['beacons-opened'] then
            global.beacons.opened = table.deepcopy(global['beacons-opened'])
            global['beacons-opened'] = nil
        end
        if global['beacons-list'] then
            global.beacons.beacons = table.deepcopy(global['beacons-list'])
            global['beacons-list'] = nil
        end
    end,
    opened = script_data.opened,
    beacons = script_data.beacons
}