local name = "iron-ingot"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[iron]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-ore",1}
	},
	result = name,
	energy_required = 2,
	category = "smelter",
	enabled = false
}
copyToHandcraft(recipe, 3)

data:extend{item,recipe}
