local name = "encased-plutonium-cell"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-f["..name.."]",
	stack_size = 200,
	subgroup = "nuclear",
	type = "item"
}

local ingredients = {
	{"plutonium-pellet",2},
	{"concrete",4}
}
local ingotrecipe = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 12,
	category = "assembling",
	enabled = false
}

data:extend({ingot,ingotrecipe})
