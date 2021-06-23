local name = "black-powder"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "j[sulfur]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"coal",1},
		{"sulfur",2}
	},
	result = name,
	energy_required = 8,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 2)

data:extend{item,recipe}
