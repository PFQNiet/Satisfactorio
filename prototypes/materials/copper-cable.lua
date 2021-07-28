-- must be called "copper-cable" to be able to actually function as cable
local name = "copper-cable"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b[copper]-b["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item",
	wire_count = 1
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"wire",2}
	},
	result = name,
	energy_required = 2,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 1)

data:extend{item, recipe}
