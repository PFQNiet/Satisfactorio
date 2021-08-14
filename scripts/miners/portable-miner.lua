local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local miner = "portable-miner"
local box = "portable-miner-box"

---@param entity LuaEntity
local function onBuilt(entity)
	-- spawn a box for this drill
	local store = entity.surface.create_entity{
		name = box,
		position = entity.position,
		force = entity.force,
		raise_built = true
	}
	entity.drop_target = store
	-- the box is the interactible element
	link.register(store, entity)
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=miner}
	}
}
