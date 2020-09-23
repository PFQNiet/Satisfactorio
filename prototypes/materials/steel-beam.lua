-- adjust vanilla steel plate
local name = "steel-beam"
local basename = "steel-plate"

local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "d[steel]-a["..basename.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"steel-ingot",4}
}
local platerecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 2/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local platerecipe2 = { -- in Constructor
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 4,
	category = "constructing",
	enabled = false
}

data:extend({platerecipe1})
data.raw.item[basename] = plate
data.raw.recipe[basename] = platerecipe2
