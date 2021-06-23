local name = "encased-industrial-beam"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[steel]-c["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"steel-beam",4},
		{"concrete",5}
	},
	result = name,
	energy_required = 10,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 5)

data:extend{item,recipe}
