local name = "versatile-framework"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.project-part",2},
	order = "b["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-2",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"modular-frame",1},
		{"steel-beam",12}
	},
	result = name,
	result_count = 2,
	energy_required = 24,
	category = "assembling",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
