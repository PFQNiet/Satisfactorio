local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local manufacturer = "manufacturer"

---@param entity LuaEntity
local function onBuilt(entity)
	io.addConnection(entity, {-3,4.5}, "input")
	io.addConnection(entity, {-1,4.5}, "input")
	io.addConnection(entity, {1,4.5}, "input")
	io.addConnection(entity, {3,4.5}, "input")
	io.addConnection(entity, {0,-4.5}, "output")
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=manufacturer}
	}
}
