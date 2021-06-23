local name = "thermal-propulsion-rocket"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-4",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"modular-engine",5},
		{"turbo-motor",2},
		{"cooling-system",6},
		{"fused-modular-frame",1}
	},
	result = name,
	result_count = 2,
	energy_required = 120,
	category = "manufacturing",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
