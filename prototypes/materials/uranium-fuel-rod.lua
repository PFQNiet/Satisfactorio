local name = "uranium-fuel-rod"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.radioactivity",{"item-description.radioactivity-high"}},
	order = "k[uranium]-b["..name.."]",
	stack_size = 50,
	subgroup = "nuclear",
	fuel_category = "nuclear",
	fuel_value = "750GJ",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"encased-uranium-cell",50},
		{"encased-industrial-beam",3},
		{"electromagnetic-control-rod",5}
	},
	result = name,
	energy_required = 150,
	category = "manufacturing",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
