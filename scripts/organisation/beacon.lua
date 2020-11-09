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
    on_configuration_changed = function()
        if not global.beacons then
            global.beacons = script_data
        end
        if global['beacon-opened'] then
            global.beacons.opened = table.deepcopy(global['beacon-opened'])
            global['beacon-opened'] = nil
        end
        if global['beacon-list'] then
            global.beacons.beacons = table.deepcopy(global['beacon-list'])
            global['beacon-list'] = nil
        end
    end,
    opened = script_data.opened,
    beacons = script_data.beacons
}
