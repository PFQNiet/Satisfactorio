local name = "aluminium-casing"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-b["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"aluminium-ingot",3}
	},
	result = name,
	result_count = 2,
	energy_required = 2,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 8)

data:extend{item,recipe}
