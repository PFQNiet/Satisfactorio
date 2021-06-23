local name = "alclad-aluminium-sheet"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-a["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"aluminium-ingot",3},
		{"copper-ingot",1}
	},
	result = name,
	result_count = 3,
	energy_required = 6,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 8)

data:extend{item,recipe}
