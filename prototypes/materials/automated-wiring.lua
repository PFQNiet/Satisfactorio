local name = "automated-wiring"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.project-part",3},
	order = "c["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-2",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"stator",1},
		{"copper-cable",20}
	},
	result = name,
	energy_required = 24,
	category = "assembling",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
