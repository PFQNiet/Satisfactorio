local bev = require(modpath.."scripts.lualib.build-events")
local miner = "oil-extractor"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == miner then
		entity.rotatable = false
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
