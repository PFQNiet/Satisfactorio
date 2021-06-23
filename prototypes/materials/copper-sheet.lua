local name = "copper-sheet"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[copper]-c["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"copper-ingot",2}
	},
	result = name,
	energy_required = 6,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe,3)

data:extend{item,recipe}
