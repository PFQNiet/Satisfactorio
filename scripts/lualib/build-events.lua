---@alias on_build on_built_entity|on_robot_built_entity|script_raised_built|script_raised_revive
---@alias on_destroy on_player_mined_entity|on_robot_mined_entity|on_entity_died|script_raised_destroy

---@class applyBuildEvents_param
---@field on_build fun(event:on_build)
---@field on_destroy fun(event:on_destroy)

---@param lib applyBuildEvents_param
---@return table
local function applyBuildEvents(lib)
	if lib.on_build then
		if not lib.events then lib.events = {} end
		lib.events[defines.events.on_built_entity] = lib.on_build
		lib.events[defines.events.on_robot_built_entity] = lib.on_build
		lib.events[defines.events.script_raised_built] = lib.on_build
		lib.events[defines.events.script_raised_revive] = lib.on_build
		lib.on_build = nil
	end

	if lib.on_destroy then
		if not lib.events then lib.events = {} end
		lib.events[defines.events.on_player_mined_entity] = lib.on_destroy
		lib.events[defines.events.on_robot_mined_entity] = lib.on_destroy
		lib.events[defines.events.on_entity_died] = lib.on_destroy
		lib.events[defines.events.script_raised_destroy] = lib.on_destroy
		lib.on_destroy = nil
	end

	return lib
end

return {
	applyBuildEvents = applyBuildEvents
}
