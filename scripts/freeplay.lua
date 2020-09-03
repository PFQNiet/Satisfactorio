-- modify default freeplay scenario
local function onInit()
	if remote.interfaces.freeplay then
		remote.call("freeplay","set_created_items",{
			-- TODO Remove this and spawn a drop pod at spawn instead
			["hub-parts"] = 1
		})
		remote.call("freeplay","set_respawn_items",{})
		remote.call("freeplay","set_skip_intro",true)
		remote.call("freeplay","set_disable_crashsite",true)
	end
end

return {
	on_init = onInit
}
