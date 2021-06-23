local name = "iron-rod"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[iron]-b["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-ingot",1}
	},
	result = name,
	energy_required = 4,
	category = "constructing"
}
copyToHandcraft(recipe,1)

data:extend{item,recipe}
