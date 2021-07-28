local name = "silica"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i[quartz]-b["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"raw-quartz",3}
	},
	result = name,
	result_count = 5,
	energy_required = 8,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 8)

data:extend{item,recipe}
