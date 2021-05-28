-- repurpose vanilla nuclear fuel
local name = "uranium-fuel-rod"
local basename = "nuclear-fuel"

local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "k[uranium]-b["..basename.."]",
	stack_size = 50,
	subgroup = "nuclear",
	fuel_category = "nuclear",
	fuel_value = "750GJ",
	type = "item"
}

local ingredients = {
	{"uranium-fuel-cell",25},
	{"encased-industrial-beam",3},
	{"electromagnetic-control-rod",5}
}
local ingotrecipe = { -- in Manufacturer
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 150,
	category = "manufacturing",
	enabled = false
}

data.raw.item[basename] = ingot
data.raw.recipe[basename] = ingotrecipe
