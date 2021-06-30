local name = "plutonium-fuel-rod"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.radioactivity",{"item-description.radioactivity-average"}},
	order = "k[uranium]-g["..name.."]",
	stack_size = 50,
	subgroup = "nuclear",
	fuel_category = "nuclear",
	fuel_value = "1500GJ",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"encased-plutonium-cell",30},
		{"steel-beam",18},
		{"electromagnetic-control-rod",6},
		{"heat-sink",10}
	},
	result = name,
	energy_required = 240,
	category = "manufacturing",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
