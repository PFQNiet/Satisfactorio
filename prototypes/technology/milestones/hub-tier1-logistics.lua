data:extend({{
	type = "technology",
	name = "hub-tier1-logistics",
	order = "a-1-2",
	icon = "__Satisfactorio__/graphics/icons/conveyor-splitter.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-6"},
	unit = {
		count = 1,
		time = 240,
		ingredients = {{"hub-tier1-logistics",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="conveyor-splitter"},
		{type="unlock-recipe",recipe="conveyor-merger"},
		{type="unlock-recipe",recipe="underground-transport-belt"}
	}
}})
