local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local blender = "blender"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == blender then
		io.addConnection(entity, {-3,3.5}, "input")
		io.addConnection(entity, {-1,3.5}, "input")
		io.addConnection(entity, {1,-3.5}, "output")
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
