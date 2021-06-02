local name = "thermal-propulsion-rocket"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-4",
	type = "item"
}

local ingredients = {
	{"modular-engine",5},
	{"turbo-motor",2},
	{"cooling-system",6},
	{"fused-modular-frame",1}
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
