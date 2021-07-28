local name = "nitric-acid"
local fluid = {
	type = "fluid",
	name = name,
	order = "d[nitro]-a["..name.."]",
	subgroup = "fluid-product",
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {240,240,180},
	flow_color = {240,240,180}
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{type="fluid",name="nitrogen-gas",amount=12},
		{type="fluid",name="water",amount=3},
		{"iron-plate",1}
	},
	results = {{type="fluid",name="nitric-acid",amount=3}},
	subgroup = "fluid-recipe",
	energy_required = 6,
	category = "blending",
	enabled = false
}

data:extend{fluid,recipe}
