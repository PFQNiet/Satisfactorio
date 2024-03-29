local name = "smart-plating"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.project-part",1},
	order = "a["..name.."]",
	stack_size = 50,
	subgroup = "space-parts-1",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"reinforced-iron-plate",1},
		{"rotor",1}
	},
	result = name,
	energy_required = 30,
	category = "assembling",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
