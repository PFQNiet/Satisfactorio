-- modify default freeplay scenario
local function onInit()
	if remote.interfaces.freeplay then
		remote.call("freeplay","set_created_items",{
			["xeno-zapper"] = 1,
			-- TODO Remove this and spawn a drop pod at spawn instead
			["hub-parts"] = 1
		})
		remote.call("freeplay","set_respawn_items",{})
		remote.call("freeplay","set_skip_intro",true)
		remote.call("freeplay","set_disable_crashsite",true)
		remote.call("freeplay","set_chart_distance",1)
		if remote.interfaces['silo-script'] then
			remote.call("silo_script", "set_no_victory", true)
		end
	end
end

return {
	on_init = onInit
}
