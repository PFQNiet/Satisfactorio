local name = "modular-engine"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.project-part",4},
	order = "d["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-3",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"motor",2},
		{"rubber",15},
		{"smart-plating",2}
	},
	result = name,
	energy_required = 60,
	category = "manufacturing",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
