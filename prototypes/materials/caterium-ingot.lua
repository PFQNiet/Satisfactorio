local name = "caterium-ingot"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "g[caterium]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local ingredients = {
	{"caterium-ore",3}
}
local ingotrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 4/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Smelter
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 4,
	category = "smelter",
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
