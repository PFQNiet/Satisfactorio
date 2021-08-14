local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local packager = "packager"

---@param entity LuaEntity
local function onBuilt(entity)
	-- square building so manually set it to not be rotatable
	entity.rotatable = false

	io.addConnection(entity, {1,2}, "input")
	io.addConnection(entity, {1,-2}, "output")
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=packager}
	}
}
