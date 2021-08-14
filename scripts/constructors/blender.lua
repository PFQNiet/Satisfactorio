local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local blender = "blender"

---@param entity LuaEntity
local function onBuilt(entity)
	io.addConnection(entity, {-3,3.5}, "input")
	io.addConnection(entity, {-1,3.5}, "input")
	io.addConnection(entity, {1,-3.5}, "output")
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=blender}
	}
}
