local name = "assembly-director-system"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-4",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"adaptive-control-unit",2},
		{"supercomputer",1}
	},
	result = name,
	energy_required = 80,
	category = "assembling",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
