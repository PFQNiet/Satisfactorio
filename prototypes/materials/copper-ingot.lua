local name = "copper-ingot"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[copper]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local ingredients = {
	{"copper-ore",1}
}
local ingotrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 3/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Smelter
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 2,
	category = "smelter",
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})