local name = "black-powder"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "j[sulfur]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local ingredients = {
	{"coal",1},
	{"sulfur",2}
}
local ingotrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 2/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 8,
	category = "assembling",
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
