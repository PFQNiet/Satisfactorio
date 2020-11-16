local name = "screw"
local basename = "iron-gear-wheel"
local screw = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "a[iron]-c["..name.."]",
	stack_size = 500,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"iron-stick",1}
}
local screwrecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	result_count = 4,
	energy_required = 3/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local screwrecipe2 = { -- in Constructor
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	result_count = 4,
	energy_required = 6,
	category = "constructing",
	enabled = false
}

data:extend({screwrecipe1})
data.raw.item[basename] = screw
data.raw.recipe[basename] = screwrecipe2
