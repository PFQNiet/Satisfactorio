local name = "heat-sink"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-b["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"alclad-aluminium-sheet",5},
		{"copper-sheet",3}
	},
	result = name,
	energy_required = 8,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 9)

data:extend{item,recipe}
