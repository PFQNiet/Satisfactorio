local bev = require(modpath.."scripts.lualib.build-events")

-- add a light to each power slug to draw attention
local colours = {
	["green-power-slug"] = {0.25,1,0.25},
	["green-power-slug-decorative"] = {0.25,1,0.25},
	["yellow-power-slug"] = {1,1,0.25},
	["yellow-power-slug-decorative"] = {1,1,0.25},
	["purple-power-slug"] = {0.5,0.25,1},
	["purple-power-slug-decorative"] = {0.5,0.25,1}
}
local names = {}
for n in pairs(colours) do table.insert(names, n) end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if not colours[entity.name] then return end
	rendering.draw_light{
		sprite = "utility/light_medium",
		color = colours[entity.name],
		scale = 2,
		intensity = 2,
		target = entity,
		surface = entity.surface
	}
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=names}
	}
}
