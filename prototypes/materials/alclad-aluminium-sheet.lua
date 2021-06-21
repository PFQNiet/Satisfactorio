local name = "alclad-aluminium-sheet"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-a["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"aluminium-ingot",3},
	{"copper-ingot",1}
}
local ingotrecipe1 = {
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 8/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 6,
	category = "assembling",
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
