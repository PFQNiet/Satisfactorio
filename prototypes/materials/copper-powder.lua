local name = "copper-powder"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[copper]-d["..name.."]",
	stack_size = 500,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"copper-ingot",30}
	},
	result = name,
	result_count = 5,
	energy_required = 6,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 10)

data:extend{item,recipe}
