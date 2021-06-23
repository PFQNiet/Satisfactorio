local name = "modular-frame"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[frame]-a["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"reinforced-iron-plate",3},
		{"iron-rod",12}
	},
	result = name,
	result_count = 2,
	energy_required = 60,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 15)

data:extend{item,recipe}
