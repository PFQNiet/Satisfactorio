-- adjust vanilla concrete
local name = "concrete"

local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[stone]-a["..name.."]",
	stack_size = 500,
	subgroup = "ingots",
	type = "item"
}

local ingredients = {
	{"stone",3}
}
local platerecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 2/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local platerecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 4,
	category = "constructing",
	enabled = false
}

data:extend({platerecipe1})
data.raw.item[name] = plate
data.raw.recipe[name] = platerecipe2