data:extend({{
	type = "technology",
	name = "hub-tier0-hub-upgrade-3",
	order = "a-0-3",
	icon = "__Satisfactorio__/graphics/icons/concrete.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-2"},
	unit = {
		count = 1,
		time = 1,
		ingredients = {{"hub-tier0-hub-upgrade-3",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="constructor"},
		{type="unlock-recipe",recipe="small-electric-pole"},
		{type="unlock-recipe",recipe="concrete"},
		{type="unlock-recipe",recipe="screw"},
		{type="unlock-recipe",recipe="reinforced-iron-plate"},
		{type="unlock-recipe",recipe="scanner-stone"}
	}
}})
