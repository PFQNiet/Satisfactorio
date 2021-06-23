local name = "radio-control-unit"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[rcu]-["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"aluminium-casing",32},
		{"crystal-oscillator",1},
		{"computer",1}
	},
	result = name,
	result_count = 2,
	energy_required = 48,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 18)

data:extend{item,recipe}
