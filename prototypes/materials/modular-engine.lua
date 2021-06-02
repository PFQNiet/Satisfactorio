local name = "modular-engine"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-3",
	type = "item"
}

local ingredients = {
	{"motor",2},
	{"rubber",15},
	{"smart-plating",2}
}
local platerecipe = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 60,
	category = "manufacturing",
	enabled = false
}

data:extend({plate,platerecipe})
