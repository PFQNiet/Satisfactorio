local name = "encased-uranium-cell"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.radioactivity",{"item-description.radioactivity-mild"}},
	order = "k[uranium]-a["..name.."]",
	stack_size = 200,
	subgroup = "nuclear",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"uranium-ore",10},
		{"concrete",3},
		{type="fluid",name="sulfuric-acid",amount=8}
	},
	results = {
		{name,5},
		{type="fluid",name="sulfuric-acid",amount=2}
	},
	main_product = name,
	energy_required = 12,
	category = "blending",
	enabled = false
}

data:extend{item,recipe}
