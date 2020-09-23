local name = "quickwire"
local wire = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "g[caterium]-a["..name.."]",
	stack_size = 500,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"caterium-ingot",1}
}
local wirerecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 5/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local wirerecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 5,
	category = "constructing",
	enabled = false
}

data:extend({wire,wirerecipe1,wirerecipe2})
