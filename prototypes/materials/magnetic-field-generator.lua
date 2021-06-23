local name = "magnetic-field-generator"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "g["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-4",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"versatile-framework",5},
		{"electromagnetic-control-rod",2},
		{"battery",10}
	},
	result = name,
	result_count = 2,
	energy_required = 120,
	category = "manufacturing",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
