local name = "adaptive-control-unit"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "e["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-3",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"automated-wiring",15},
		{"circuit-board",10},
		{"heavy-modular-frame",2},
		{"computer",2}
	},
	result = name,
	result_count = 2,
	energy_required = 120,
	category = "manufacturing",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
