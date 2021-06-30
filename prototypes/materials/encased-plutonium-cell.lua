local name = "encased-plutonium-cell"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.radioactivity",{"item-description.radioactivity-high"}},
	order = "k[uranium]-f["..name.."]",
	stack_size = 200,
	subgroup = "nuclear",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"plutonium-pellet",2},
		{"concrete",4}
	},
	result = name,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
