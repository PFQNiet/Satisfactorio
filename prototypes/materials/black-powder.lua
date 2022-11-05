local name = "black-powder"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "j[sulfur]-a["..name.."]",
	stack_size = 200,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"coal",1},
		{"sulfur",1}
	},
	result = name,
	result_count = 2,
	energy_required = 4,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 2)

data:extend{item,recipe}
