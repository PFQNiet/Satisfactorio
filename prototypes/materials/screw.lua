local name = "screw"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[iron]-c["..name.."]",
	stack_size = 500,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-rod",1}
	},
	result = name,
	result_count = 4,
	energy_required = 6,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 3)

data:extend{item,recipe}
