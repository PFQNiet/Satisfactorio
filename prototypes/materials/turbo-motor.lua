local name = "turbo-motor"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[motor]-d["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"heat-sink",4},
		{"radio-control-unit",2},
		{"motor",4},
		{"rubber",24}
	},
	result = name,
	energy_required = 32,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 32)

data:extend{item,recipe}
