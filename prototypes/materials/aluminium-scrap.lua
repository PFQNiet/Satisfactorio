local name = "aluminium-scrap"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-b["..name.."]",
	stack_size = 500,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{type="fluid",name="alumina-solution",amount=4},
		{"coal",2}
	},
	results = {
		{name,6},
		{type="fluid",name="water",amount=2}
	},
	main_product = name,
	energy_required = 1,
	category = "refining",
	enabled = false
}

data:extend{item,recipe}
