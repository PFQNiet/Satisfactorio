local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local foundry = "foundry"

---@param entity LuaEntity
local function onBuilt(entity)
	io.addConnection(entity, {-1,1.5}, "input")
	io.addConnection(entity, {1,1.5}, "input")
	io.addConnection(entity, {1,-1.5}, "output")
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=foundry}
	}
}
