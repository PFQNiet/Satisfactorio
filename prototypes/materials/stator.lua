local name = "stator"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[motor]-b["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"steel-pipe",3},
		{"wire",8}
	},
	result = name,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 9)

data:extend{item,recipe}
