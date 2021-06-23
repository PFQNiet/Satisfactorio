local name = "motor"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[motor]-c["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"rotor",2},
		{"stator",2}
	},
	result = name,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 12)

data:extend{item,recipe}
