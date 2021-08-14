local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local smelter = "smelter"

---@param entity LuaEntity
local function onBuilt(entity)
	io.addConnection(entity, {0,2}, "input")
	io.addConnection(entity, {0,-2}, "output")
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=smelter}
	}
}
