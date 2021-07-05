local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local smelter = "foundry"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == smelter then
		io.addConnection(entity, {-1,1.5}, "input")
		io.addConnection(entity, {1,1.5}, "input")
		io.addConnection(entity, {1,-1.5}, "output")
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
