local name = "battery"
local item = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	subgroup = "parts",
	order = "h[bauxite]-c["..name.."]",
	stack_size = 200,
	fuel_category = "battery",
	fuel_value = "6GJ"
}

local ingredients = {
	{type="fluid",name="sulfuric-acid",amount=2.5},
	{type="fluid",name="alumina-solution",amount=2},
	{"aluminium-casing",1}
}
local recipe = { -- in blender
	name = name,
	type = "recipe",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	ingredients = ingredients,
	results = {
		{name,1},
		{type="fluid",name="water",amount=1.5}
	},
	main_product = name,
	energy_required = 3,
	category = "blending",
	enabled = false
}
data:extend({item,recipe})
