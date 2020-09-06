data:extend({{
	type = "technology",
	name = "hub-tier0-hub-upgrade-2",
	order = "a-0-2",
	icon = "__Satisfactorio__/graphics/icons/copper-ingot.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-1"},
	unit = {
		count = 1,
		time = 1,
		ingredients = {{"hub-tier0-hub-upgrade-2",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="smelter"},
		{type="unlock-recipe",recipe="copper-ingot"},
		{type="unlock-recipe",recipe="wire"},
		{type="unlock-recipe",recipe="copper-cable"},
		{type="unlock-recipe",recipe="scanner-copper-ore"},
		{type="nothing",effect_description={"technology-effect.add-biomass-burner-to-hub"}}
	}
}})
