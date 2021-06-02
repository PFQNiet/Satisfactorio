local name = "nuclear-pasta"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-4",
	type = "item"
}

local ingredients = {
	{"copper-powder",200},
	{"pressure-conversion-cube",1}
}
local platerecipe = { -- in Particle Accelerator
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 120,
	category = "accelerating",
	enabled = false
}

data:extend({plate,platerecipe})
