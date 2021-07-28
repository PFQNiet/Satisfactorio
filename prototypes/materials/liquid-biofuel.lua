local name = "liquid-biofuel"
local fluid = {
	type = "fluid",
	name = name,
	order = "c[fuel]-b["..name.."]",
	subgroup = "fluid-fuel",
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {21,72,0},
	flow_color = {106,138,74},
	fuel_value = "750MJ"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"solid-biofuel",6},
		{type="fluid",name="water",amount=3}
	},
	results = {{type="fluid",name="liquid-biofuel",amount=4}},
	subgroup = "fluid-recipe",
	energy_required = 4,
	category = "refining",
	enabled = false
}

data:extend{fluid,recipe}
