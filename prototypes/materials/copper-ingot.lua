local name = "copper-ingot"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c["..name.."]",
	stack_size = 100,
	subgroup = "raw-material",
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
	category = "crafting"
}
local ingotrecipe2 = { -- in Smelter
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 2,
	category = "smelting",
	hide_from_player_crafting = true
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})