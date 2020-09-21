local name = "fuel"

local fluid = {
	type = "fluid",
	name = name,
	order = "s["..name.."]",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {169,94,31},
	flow_color = {255,182,77},
	fuel_value = "600MJ"
}

local ingredients = {
	{type="fluid",name="heavy-oil",amount=6}
}
local recipe = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = ingredients,
	results = {{type="fluid",name=name,amount=4}},
	energy_required = 6,
	category = "refining",
	enabled = false
}

data:extend({fluid,recipe})
