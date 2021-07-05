local bev = require(modpath.."scripts.lualib.build-events")

-- it already has 9999 health, let's make it invulnerable for good measure!
local name = "spore-flower"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name ~= name then return end
	entity.destructible = false
end
-- vulnerability to Nobelisk is part of the Nobelisk explosion code

return bev.applyBuildEvents{
	on_build = onBuilt
}
