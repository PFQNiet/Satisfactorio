local name = "magnetic-field-generator"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "g["..name.."]",
	stack_size = 50,
	subgroup = "space-parts",
	type = "item"
}

local ingredients = {
	{"versatile-framework",5},
	{"electromagnetic-control-rod",2},
	{"battery",10}
}
local platerecipe = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 120,
	category = "manufacturing",
	enabled = false
}

data:extend({plate,platerecipe})
