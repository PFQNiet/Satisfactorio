local name = "radio-control-unit"
local rcu = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[rcu]-["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"heat-sink",4},
	{"rubber",16},
	{"crystal-oscillator",1},
	{"computer",1}
}
local rcurecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 18/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local rcurecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 24,
	category = "manufacturing",
	enabled = false
}

data:extend({rcu,rcurecipe1,rcurecipe2})
