-- add compatibility for Construction Drones
local mod = "Construction_Drones"
if mods[mod] then
	local names = require("__"..mod.."__.shared")
	local recipe = data.raw.recipe[names.units.construction_drone]
	recipe.category = "equipment"
	recipe.energy_required = 8/4
	-- replace green circuits with a.i. limiter
	recipe.ingredients[3] = {"processing-unit",1}
	recipe.enabled = false
	recipe.hide_from_stats = true

	-- by default these are available from the start of the game, so let's move them to the Caterium MAM tree to allow for rushing them if desired
	local addTech = require("prototypes.technology")
	local tech = addTech("mam-caterium-construction-drone", {
		filename = "__"..mod.."__/data/units/construction_drone/construction_drone_technology.png",
		size = 150
	}, "mam", "mam-caterium", "m-2-9-[construction-drone]", 3, {"mam-caterium-ai-limiter"}, {
		{"processing-unit",10},
		{"screw",50}
	}, {
		{type="unlock-recipe",recipe=names.units.construction_drone}
	})
	tech.tool.localised_name = data.raw.item[names.units.construction_drone].localised_name
	tech.recipe.localised_name = data.raw.item[names.units.construction_drone].localised_name
	tech.recipe_done.localised_name = data.raw.item[names.units.construction_drone].localised_name
	tech.technology.localised_name = data.raw.item[names.units.construction_drone].localised_name
end
