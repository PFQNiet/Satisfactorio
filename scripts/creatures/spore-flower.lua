local bev = require(modpath.."scripts.lualib.build-events")

-- it already has 9999 health, let's make it invulnerable for good measure!
local name = "spore-flower"

---@param entity LuaEntity
local function onBuilt(entity)
	entity.destructible = false
end
-- vulnerability to Nobelisk is part of the Nobelisk explosion code

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=name}
	}
}
