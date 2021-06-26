local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local miners = {
	["miner-mk-1"] = true,
	["miner-mk-2"] = true,
	["miner-mk-3"] = true
}
local box = "miner-box"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	local name = entity.name
	if miners[name] then
		-- spawn a box for this drill
		local store = entity.surface.create_entity{
			name = box,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		link.register(entity,store)

		io.addConnection(entity, {0,-6}, "output", store)
		entity.rotatable = false
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
