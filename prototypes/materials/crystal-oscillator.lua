local name = "crystal-oscillator"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i[quartz]-a["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"quartz-crystal",36},
		{"copper-cable",28},
		{"reinforced-iron-plate",5}
	},
	result = name,
	result_count = 2,
	energy_required = 120,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 18)

data:extend{item,recipe}
