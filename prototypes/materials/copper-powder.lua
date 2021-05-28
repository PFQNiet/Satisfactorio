local name = "copper-powder"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[copper]-d["..name.."]",
	stack_size = 500,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"copper-ingot",30}
}
local ingotrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 10/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 6,
	category = "constructing",
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
