local name = "computer"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[computer]-d["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"circuit-board",10},
		{"copper-cable",9},
		{"plastic",18},
		{"screw",52}
	},
	result = name,
	energy_required = 24,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 18)

data:extend{item,recipe}
