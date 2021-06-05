local name = "fuel"

local fluid = {
	type = "fluid",
	name = name,
	order = "c[fuel]-a["..name.."]",
	subgroup = "fluid-fuel",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {169,94,31},
	flow_color = {255,182,77},
	fuel_value = "750MJ"
}

local recipe1 = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = {{type="fluid",name="crude-oil",amount=6}},
	results = {
		{type="fluid",name=name,amount=4},
		{"polymer-resin",3}
	},
	main_product = name,
	subgroup = "fluid-recipe",
	energy_required = 6,
	category = "refining",
	order = fluid.order.."-a",
	enabled = false
}
local recipe2 = { -- Residual
	name = "residual-"..name,
	localised_name = {"recipe-name.residual-"..name},
	type = "recipe",
	ingredients = {{type="fluid",name="heavy-oil",amount=6}},
	results = {{type="fluid",name=name,amount=4}},
	subgroup = "fluid-recipe",
	energy_required = 6,
	category = "refining",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/heavy-oil-residue.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	order = fluid.order.."-b",
	enabled = false
}

data:extend({fluid,recipe1,recipe2})
