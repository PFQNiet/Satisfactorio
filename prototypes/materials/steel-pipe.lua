local name = "steel-pipe"
local pipe = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[steel]-b["..name.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"steel-ingot",3}
}
local piperecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 3/4,
	category = "craft-bench",
	enabled = false
}
local piperecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 6,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({pipe,piperecipe1,piperecipe2})
