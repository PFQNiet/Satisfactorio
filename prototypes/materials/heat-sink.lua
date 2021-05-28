local name = "heat-sink"
local sink = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-b["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"alclad-aluminium-sheet",5},
	{"copper-plate",3}
}
local sinkrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 9/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local sinkrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 8,
	category = "assembling",
	enabled = false
}

data:extend({sink,sinkrecipe1,sinkrecipe2})
