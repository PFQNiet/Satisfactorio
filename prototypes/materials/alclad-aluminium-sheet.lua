local name = "alclad-aluminium-sheet"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[aluminium]-c["..name.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"aluminium-ingot",8},
	{"copper-ingot",3}
}
local ingotrecipe1 = {
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 8/4,
	category = "craft-bench",
	enabled = false
}
local ingotrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 8,
	category = "assembling",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
