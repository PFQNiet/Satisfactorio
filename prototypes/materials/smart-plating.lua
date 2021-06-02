local name = "smart-plating"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-1",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",1},
	{"rotor",1}
}
local platerecipe = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 30,
	category = "assembling",
	enabled = false
}

data:extend({plate,platerecipe})
