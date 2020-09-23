local name = "supercomputer"
local computer = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"computer",2},
	{"processing-unit",2},
	{"advanced-circuit",3},
	{"plastic-bar",28}
}
local computerrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 24/4,
	category = "craft-bench",
	enabled = false
}
local computerrecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 32,
	category = "manufacturing",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({computer,computerrecipe1,computerrecipe2})
