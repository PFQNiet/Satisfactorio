local name = "turbofuel"
local fluid = {
	type = "fluid",
	name = name,
	order = "c[fuel]-c["..name.."]",
	subgroup = "fluid-fuel",
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {103,1,5},
	flow_color = {168,0,13},
	fuel_value = "2GJ"
}

local recipe = {
	name = "turbofuel",
	type = "recipe",
	ingredients = {
		{type="fluid",name="fuel",amount=6},
		{"compacted-coal",4}
	},
	results = {{type="fluid",name="turbofuel",amount=5}},
	main_product = "turbofuel",
	subgroup = "fluid-recipe",
	energy_required = 16,
	category = "refining",
	enabled = false
}

data:extend{fluid, recipe}
