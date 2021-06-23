local name = "plutonium-pellet"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-e["..name.."]",
	stack_size = 100,
	subgroup = "nuclear",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"non-fissile-uranium",100},
		{"uranium-waste",25}
	},
	result = name,
	result_count = 30,
	energy_required = 60,
	category = "accelerating",
	enabled = false
}
-- no handcrafting

data:extend{item,recipe}
