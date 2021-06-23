local name = "concrete"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[stone]-a["..name.."]",
	stack_size = 500,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"stone",3}
	},
	result = name,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)

data:extend{item,recipe}
