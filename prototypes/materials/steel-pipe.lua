local name = "steel-pipe"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[steel]-b["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"steel-ingot",3}
	},
	result = name,
	result_count = 2,
	energy_required = 6,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 3)

data:extend{item,recipe}
