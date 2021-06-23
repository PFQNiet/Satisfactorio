local name = "ai-limiter"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[computer]-c["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"copper-sheet",5},
		{"quickwire",20}
	},
	result = name,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 6)

data:extend{item,recipe}
