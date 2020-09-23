local name = "uranium-pellet"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-a["..name.."]",
	stack_size = 200,
	subgroup = "nuclear",
	type = "item"
}

local ingredients = {
	{"uranium-ore",5},
	{type="fluid",name="sulfuric-acid",amount=8}
}
local ingotrecipe = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{name,5},
		{type="fluid",name="sulfuric-acid",amount=2}
	},
	main_product = name,
	energy_required = 6,
	category = "refining",
	enabled = false
}

data:extend({ingot,ingotrecipe})
