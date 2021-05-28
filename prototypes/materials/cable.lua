-- repurpose vanilla copper cable
local name = "cable"
local basename = "copper-cable"

local cable = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "b[copper]-b["..basename.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"wire",2}
}
local cablerecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 1/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local cablerecipe2 = { -- in Constructor
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 2,
	category = "constructing",
	enabled = false
}

data:extend({cablerecipe1})
data.raw.item[basename] = cable
data.raw.recipe[basename] = cablerecipe2