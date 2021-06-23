local name = "nuclear-pasta"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-4",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"copper-powder",200},
		{"pressure-conversion-cube",1}
	},
	result = name,
	energy_required = 120,
	category = "accelerating",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
