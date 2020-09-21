-- adjust vanilla plastic bar
local name = "plastic"
local basename = "plastic-bar"

local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "e[oil]-a["..name.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
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
	enabled = false
}

data.raw.item[basename] = plate
data.raw.recipe[basename] = platerecipe
