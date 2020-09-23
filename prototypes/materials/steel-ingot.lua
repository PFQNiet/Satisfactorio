local name = "steel-ingot"
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
	{"iron-ore",3},
	{"coal",3}
}
local ingotrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 6/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Foundry
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 4,
	category = "foundry",
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
