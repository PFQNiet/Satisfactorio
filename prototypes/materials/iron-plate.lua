-- adjust vanilla iron plate
local name = "iron-plate"

local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[iron]-a["..name.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"iron-ingot",3}
}
local platerecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 3/4,
	category = "craft-bench"
}
local platerecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 6,
	category = "constructing",
	hide_from_player_crafting = true
}

data:extend({platerecipe1})
data.raw.item[name] = plate
data.raw.recipe[name] = platerecipe2