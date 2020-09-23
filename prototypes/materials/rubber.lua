local name = "rubber"
local rubber = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f[oil]-b["..name.."]",
	stack_size = 100,
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
	enabled = false
}

data:extend({rubber,rubberrecipe})
