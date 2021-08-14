local bev = require(modpath.."scripts.lualib.build-events")
local miner = "oil-extractor"

---@param entity LuaEntity
local function onBuilt(entity)
	entity.rotatable = false
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=miner}
	}
}
