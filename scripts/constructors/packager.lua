local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local packager = "packager"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == packager then
		-- square building so manually set it to not be rotatable
		entity.rotatable = false

		io.addConnection(entity, {1,2}, "input")
		io.addConnection(entity, {1,-2}, "output")
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
