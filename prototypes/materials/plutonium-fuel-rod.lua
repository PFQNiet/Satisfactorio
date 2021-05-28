local name = "plutonium-fuel-rod"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-g["..name.."]",
	stack_size = 50,
	subgroup = "nuclear",
	fuel_category = "nuclear",
	fuel_value = "1500GJ",
	type = "item"
}

local ingredients = {
	{"encased-plutonium-cell",30},
	{"steel-plate",18},
	{"electromagnetic-control-rod",6},
	{"heat-sink",10}
}
local ingotrecipe = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 240,
	category = "manufacturing",
	enabled = false
}

data:extend({ingot,ingotrecipe})
