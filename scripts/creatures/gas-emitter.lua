local bev = require(modpath.."scripts.lualib.build-events")

-- it already has 9999 health, let's make it invulnerable for good measure!
local name = "gas-emitter"

---@param entity LuaEntity
local function onBuilt(entity)
	entity.destructible = false
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=name}
	}
}
