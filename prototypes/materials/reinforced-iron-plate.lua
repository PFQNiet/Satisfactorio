local name = "reinforced-iron-plate"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[iron]-d["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-plate",6},
		{"screw",12}
	},
	result = name,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 6)

data:extend{item,recipe}
