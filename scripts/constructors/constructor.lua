local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local constructor = "constructor"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == constructor then
		io.addConnection(entity, {0,2}, "input")
		io.addConnection(entity, {0,-2}, "output")
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
