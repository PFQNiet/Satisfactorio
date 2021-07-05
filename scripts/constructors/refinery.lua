local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local refinery = "refinery"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == refinery then
		io.addConnection(entity, {1,4.5}, "input")
		io.addConnection(entity, {1,-4.5}, "output")
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
