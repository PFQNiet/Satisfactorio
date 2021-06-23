local name = "rotor"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[motor]-a["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-rod",5},
		{"screw",25}
	},
	result = name,
	energy_required = 15,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 6)

data:extend{item,recipe}
