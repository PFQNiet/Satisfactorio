local name = "non-fissile-uranium"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.radioactivity",{"item-description.radioactivity-mild"}},
	order = "k[uranium]-d["..name.."]",
	stack_size = 500,
	subgroup = "nuclear",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"uranium-waste",15},
		{"silica",10},
		{type="fluid",name="nitric-acid",amount=6},
		{type="fluid",name="sulfuric-acid",amount=6}
	},
	results = {
		{name,20},
		{type="fluid",name="water",amount=6}
	},
	main_product = name,
	energy_required = 24,
	category = "blending",
	enabled = false
}

data:extend{item,recipe}
