local name = "non-fissile-uranium"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-d["..name.."]",
	stack_size = 500,
	subgroup = "nuclear",
	type = "item"
}

local ingredients = {
	{"uranium-waste",15},
	{"silica",10},
	{type="fluid",name="nitric-acid",amount=6},
	{type="fluid",name="sulfuric-acid",amount=6}
}
local ingotrecipe = { -- in Blender
	name = name,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{name,20},
		{type="fluid",name="water",amount=6}
	},
	main_product = name,
	energy_required = 24,
	category = "blending",
	enabled = false
}

data:extend({ingot,ingotrecipe})
