local name = "wire"
local wire = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[copper]-a["..name.."]",
	stack_size = 500,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"copper-ingot",1}
}
local wirerecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 2/4,
	category = "craft-bench",
	enabled = false
}
local wirerecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 3,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({wire,wirerecipe1,wirerecipe2})