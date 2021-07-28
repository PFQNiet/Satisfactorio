local name = "steel-ingot"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[steel]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-ore",3},
		{"coal",3}
	},
	result = name,
	result_count = 3,
	energy_required = 4,
	category = "foundry",
	enabled = false
}
copyToHandcraft(recipe, 6)

data:extend{item,recipe}
