local name = "alumina-solution"

local fluid = {
	type = "fluid",
	name = name,
	subgroup = "fluid-product",
	order = "b["..name.."]",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {222,222,222},
	flow_color = {222,222,222}
}

local ingredients = {
	{"bauxite",7},
	{type="fluid",name="water",amount=10}
}
local recipe = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{type="fluid",name=name,amount=8},
		{"silica",2}
	},
	main_product = name,
	energy_required = 6,
	category = "refining",
	enabled = false
}

data:extend({fluid, recipe})
