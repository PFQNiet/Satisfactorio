-- repurpose vanilla copper plate
local name = "copper-sheet"
local basename = "copper-plate"

local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "c["..basename.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"copper-ingot",2}
}
local ingotrecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 3/4,
	category = "craft-bench",
	enabled = false
}
local ingotrecipe2 = { -- in Constructor
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 6,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({ingotrecipe1})
data.raw.item[basename] = ingot
data.raw.recipe[basename] = ingotrecipe2