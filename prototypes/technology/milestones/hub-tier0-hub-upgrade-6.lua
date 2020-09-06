data:extend({{
	type = "technology",
	name = "hub-tier0-hub-upgrade-6",
	order = "a-0-6",
	icon = "__Satisfactorio__/graphics/icons/mycelia.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-5"},
	unit = {
		count = 1,
		time = 1,
		ingredients = {{"hub-tier0-hub-upgrade-6",1}},
	},
	effects = {
		--{type="unlock-recipe",recipe="space-elevator"},
		--{type="unlock-recipe",recipe="biomass-burner"},
		{type="unlock-recipe",recipe="biomass-from-leaves"},
		{type="unlock-recipe",recipe="biomass-from-wood"},
		{type="nothing",effect_description={"technology-effect.add-ficsit-freighter-to-hub"}}
	}
}})
