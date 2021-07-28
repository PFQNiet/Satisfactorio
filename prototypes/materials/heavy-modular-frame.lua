local name = "heavy-modular-frame"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[frame]-b["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"modular-frame",5},
		{"steel-pipe",15},
		{"encased-industrial-beam",5},
		{"screw",100}
	},
	result = name,
	energy_required = 30,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 9)

data:extend{item,recipe}
