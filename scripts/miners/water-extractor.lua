local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local extractor = "water-extractor"
local placeholder = extractor.."-placeholder"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == placeholder then
		-- swap it for the non-placeholder and spawn a "water resource node" under it
		local resource = entity.surface.create_entity{
			name = "water",
			position = entity.position,
			force = game.forces.neutral,
			amount = 60
		}
		local miner = entity.surface.create_entity{
			name = extractor,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		link.register(miner, resource)

		local fish = entity.surface.find_entities_filtered{area=entity.selection_box, type="fish"}
		for _,f in pairs(fish) do
			f.destroy()
		end
		entity.destroy()
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
