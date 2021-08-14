local bev = require(modpath.."scripts.lualib.build-events")

-- all entities made / modded by Satisfactorio will have 1 HP and should be set to indestructible
---@param entity LuaEntity
local function onBuilt(entity)
	entity.destructible = false
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {
			---@param entity LuaEntity
			callback = function(entity) return entity.is_entity_with_health and entity.prototype.max_health == 1 end
		}
	}
}
