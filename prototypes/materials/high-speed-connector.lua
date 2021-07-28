local name = "high-speed-connector"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[computer]-b["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local recipe = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = {
		{"quickwire",56},
		{"copper-cable",10},
		{"circuit-board",1}
	},
	result = name,
	energy_required = 16,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 8)

data:extend{item,recipe}
