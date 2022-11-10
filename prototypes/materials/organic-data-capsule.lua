local name = "organic-data-capsule"
local item = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "r[remains]-r["..name.."]",
	stack_size = 50
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"alien-protein",1}
	},
	result = name,
	energy_required = 6,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 4)

data:extend{item, recipe}
