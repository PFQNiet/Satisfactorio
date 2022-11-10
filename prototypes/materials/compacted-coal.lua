local name = "compacted-coal"
local item = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "mineral-resource",
	order = "e[coal]-b["..name.."]",
	stack_size = 100,
	fuel_category = "carbon",
	fuel_value = "630MJ"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"coal",5},
		{"sulfur",5}
	},
	result = name,
	result_count = 5,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 4)

data:extend{item,recipe}
