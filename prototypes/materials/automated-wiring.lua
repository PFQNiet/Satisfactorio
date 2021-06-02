local name = "automated-wiring"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-2",
	type = "item"
}

local ingredients = {
	{"stator",1},
	{"copper-cable",20}
}
local platerecipe = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 24,
	category = "assembling",
	enabled = false
}

data:extend({plate,platerecipe})
