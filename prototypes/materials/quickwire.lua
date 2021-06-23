local name = "quickwire"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "g[caterium]-a["..name.."]",
	stack_size = 500,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"caterium-ingot",1}
	},
	result = name,
	result_count = 5,
	energy_required = 5,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 5)

data:extend{item,recipe}
