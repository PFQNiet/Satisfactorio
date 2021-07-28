local name = "aluminium-ingot"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-c["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"aluminium-scrap",6},
		{"silica",5}
	},
	result = name,
	result_count = 4,
	energy_required = 4,
	category = "foundry",
	icons = {
		{ icon = graphics.."icons/"..name..".png", icon_size = 64 },
		{ icon = graphics.."icons/silica.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	enabled = false
}
copyToHandcraft(recipe, 5)

data:extend{item,recipe}
