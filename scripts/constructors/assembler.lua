local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local assembler = "assembler"

---@param entity LuaEntity
local function onBuilt(entity)
	io.addConnection(entity, {-1,3}, "input")
	io.addConnection(entity, {1,3}, "input")
	io.addConnection(entity, {0,-3}, "output")
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=assembler}
	}
}
