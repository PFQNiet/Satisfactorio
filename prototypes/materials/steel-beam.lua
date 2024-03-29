local name = "steel-beam"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[steel]-a["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"steel-ingot",4}
	},
	result = name,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)

data:extend{item,recipe}
