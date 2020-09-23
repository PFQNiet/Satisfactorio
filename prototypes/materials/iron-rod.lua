-- adjust vanilla iron stick
local name = "iron-rod"
local basename = "iron-stick"

local rod = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "a[iron]-b["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"iron-ingot",1}
}
local rodrecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 1/4,
	category = "craft-bench",
	hide_from_player_crafting = true
}
local rodrecipe2 = { -- in Smelter
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 4,
	category = "constructing"
}

data:extend({rodrecipe1})
data.raw.item[basename] = rod
data.raw.recipe[basename] = rodrecipe2