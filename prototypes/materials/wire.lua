local name = "wire"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[copper]-a["..name.."]",
	stack_size = 500,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"copper-ingot",1}
	},
	result = name,
	result_count = 2,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)

data:extend{item,recipe}
