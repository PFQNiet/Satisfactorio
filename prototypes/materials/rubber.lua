local name = "rubber"
local rubber = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f[oil]-b["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{type="fluid",name="crude-oil",amount=3}
}
local rubberrecipe = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{name,2},
		{type="fluid",name="heavy-oil",amount=2}
	},
	main_product = name,
	energy_required = 6,
	category = "refining",
	order = rubber.order.."-a",
	enabled = false
}
local residualrecipe = {
	name = "residual-"..name,
	localised_name = {"recipe-name.residual-"..name},
	type = "recipe",
	ingredients = {
		{"polymer-resin",4},
		{type="fluid",name="water",amount=4}
	},
	results = {{name,2}},
	energy_required = 6,
	category = "refining",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/polymer-resin.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	order = rubber.order.."-b",
	allow_decomposition = false,
	enabled = false
}

data:extend({rubber,rubberrecipe,residualrecipe})
