local name = "caterium-ingot"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "g[caterium]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"caterium-ore",3}
	},
	result = name,
	energy_required = 4,
	category = "smelter",
	enabled = false
}
copyToHandcraft(recipe, 4)

data:extend{item,recipe}
