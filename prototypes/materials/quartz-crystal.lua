local name = "quartz-crystal"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i[quartz]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = {
		{"raw-quartz",5}
	},
	result = name,
	result_count = 3,
	energy_required = 8,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 8)

data:extend{item,recipe}
