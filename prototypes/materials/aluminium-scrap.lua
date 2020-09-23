local name = "aluminium-scrap"
local scrap = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-b["..name.."]",
	stack_size = 500,
	subgroup = "ingots",
	type = "item"
}

local ingredients = {
	{type="fluid",name="alumina-solution",amount=4},
	{"petroleum-coke",1}
}
local scraprecipe = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{name,6},
		{type="fluid",name="water",amount=1}
	},
	main_product = name,
	energy_required = 1,
	category = "refining",
	enabled = false
}

data:extend({scrap,scraprecipe})
