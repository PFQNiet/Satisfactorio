data:extend({{
	type = "technology",
	name = "hub-tier1-base-building",
	order = "a-1-1",
	icon = "__Satisfactorio__/graphics/icons/foundation.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-6"},
	unit = {
		count = 1,
		time = 120,
		ingredients = {{"hub-tier1-base-building",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="lookout-tower"},
		{type="unlock-recipe",recipe="foundation"},
		{type="unlock-recipe",recipe="stone-wall"}
	}
}})
