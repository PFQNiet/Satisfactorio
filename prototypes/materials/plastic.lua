-- adjust vanilla plastic bar
local name = "plastic"
local basename = "plastic-bar"

local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "f[oil]-a["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{type="fluid",name="crude-oil",amount=3}
}
local platerecipe = { -- in Refinery
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{basename,2},
		{type="fluid",name="heavy-oil",amount=1}
	},
	main_product = basename,
	energy_required = 6,
	category = "refining",
	order = plate.order.."-a",
	enabled = false
}
local residualrecipe = {
	name = "residual-"..name,
	localised_name = {"recipe-name.residual-"..name},
	type = "recipe",
	ingredients = {
		{"polymer-resin",6},
		{type="fluid",name="water",amount=2}
	},
	results = {{basename,2}},
	energy_required = 6,
	category = "refining",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/polymer-resin.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	order = plate.order.."-b",
	allow_decomposition = false,
	enabled = false
}

data.raw.item[basename] = plate
data.raw.recipe[basename] = platerecipe
data:extend{residualrecipe}
