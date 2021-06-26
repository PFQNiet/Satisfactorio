local bev = require(modpath.."scripts.lualib.build-events")

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.health == 1 then -- all entities made / modded by Satisfactorio will have 1 HP
		entity.destructible = false
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
