local name = "alumina-solution"
local fluid = {
	type = "fluid",
	name = name,
	subgroup = "fluid-product",
	order = "b[fluid-products]-b["..name.."]",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {222,222,222},
	flow_color = {222,222,222}
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"bauxite",12},
		{type="fluid",name="water",amount=18}
	},
	results = {
		{type="fluid",name=name,amount=12},
		{"silica",5}
	},
	main_product = name,
	subgroup = "fluid-recipe",
	energy_required = 6,
	category = "refining",
	enabled = false
}

data:extend{fluid,recipe}
