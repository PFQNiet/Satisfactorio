local name = "circuit-board"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[computer]-a["..name.."]",
	stack_size = 200,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"copper-sheet",2},
		{"plastic",4}
	},
	result = name,
	energy_required = 8,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 6)

data:extend{item,recipe}
