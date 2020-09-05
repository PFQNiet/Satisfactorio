local name = "screw"
local screw = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b["..name.."]",
	stack_size = 500,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"iron-stick",1}
}
local screwrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 3/4,
	category = "craft-bench",
	enabled = false
}
local screwrecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 6,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({screw,screwrecipe1,screwrecipe2})