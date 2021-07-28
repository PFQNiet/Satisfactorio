local name = "supercomputer"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[computer]-e["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"computer",2},
		{"ai-limiter",2},
		{"high-speed-connector",3},
		{"plastic",28}
	},
	result = name,
	energy_required = 32,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 24)

data:extend{item,recipe}
