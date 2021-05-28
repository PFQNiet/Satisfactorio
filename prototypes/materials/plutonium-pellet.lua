local name = "plutonium-pellet"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-e["..name.."]",
	stack_size = 100,
	subgroup = "nuclear",
	type = "item"
}

local ingredients = {
	{"non-fissile-uranium",100},
	{"uranium-waste",25}
}
local ingotrecipe = { -- in Particle Accelerator
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 30,
	energy_required = 60,
	category = "accelerating",
	enabled = false
}

data:extend({ingot,ingotrecipe})
