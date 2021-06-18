local name = "adaptive-control-unit"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "e["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-3",
	type = "item"
}

local ingredients = {
	{"automated-wiring",15},
	{"electronic-circuit",10},
	{"heavy-modular-frame",2},
	{"computer",2}
}
local platerecipe = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 120,
	category = "manufacturing",
	enabled = false
}

data:extend({plate,platerecipe})
