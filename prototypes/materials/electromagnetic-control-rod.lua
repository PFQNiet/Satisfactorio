local name = "electromagnetic-control-rod"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-c["..name.."]",
	stack_size = 100,
	subgroup = "nuclear",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"stator",3},
		{"ai-limiter",2}
	},
	result = name,
	result_count = 2,
	energy_required = 30,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 15)

data:extend{item,recipe}
