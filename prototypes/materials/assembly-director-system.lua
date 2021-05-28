local name = "assembly-director-system"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f["..name.."]",
	stack_size = 50,
	subgroup = "space-parts",
	type = "item"
}

local ingredients = {
	{"adaptive-control-unit",2},
	{"supercomputer",1}
}
local platerecipe = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 80,
	category = "assembling",
	enabled = false
}

data:extend({plate,platerecipe})
