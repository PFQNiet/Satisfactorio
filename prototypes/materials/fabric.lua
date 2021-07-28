local name = "fabric"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "m[mycelia]-a["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"mycelia",1},
		{"biomass",5}
	},
	result = name,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)

data:extend{item,recipe}
