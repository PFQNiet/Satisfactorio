local name = "stator"
local stator = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[motor]-b["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"steel-pipe",3},
	{"wire",8}
}
local statorrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 9/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local statorrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 12,
	category = "assembling",
	enabled = false
}

data:extend({stator,statorrecipe1,statorrecipe2})
