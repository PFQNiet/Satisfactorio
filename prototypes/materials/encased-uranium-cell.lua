-- repurpose vanilla uranium cell
local name = "encased-uranium-cell"
local basename = "uranium-fuel-cell"

local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "k[uranium]-a["..basename.."]",
	stack_size = 200,
	subgroup = "nuclear",
	type = "item"
}

local ingredients = {
	{"uranium-ore",10},
	{"concrete",3},
	{type="fluid",name="sulfuric-acid",amount=8}
}
local ingotrecipe = { -- in Blender
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{name,5},
		{type="fluid",name="sulfuric-acid",amount=2}
	},
	main_product = name,
	energy_required = 12,
	category = "blending",
	enabled = false
}

data.raw.item[basename] = ingot
data.raw.recipe[basename] = ingotrecipe
