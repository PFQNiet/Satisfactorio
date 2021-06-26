local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local miner = "portable-miner"
local box = "portable-miner-box"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == miner then
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
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
