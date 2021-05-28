local name = "cooling-system"
local sink = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-c["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"heat-sink",2},
	{"rubber",2},
	{type="fluid", name="water", amount=5},
	{type="fluid", name="nitrogen-gas", amount=25}
}
local sinkrecipe = { -- in Blender
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 10,
	category = "blending",
	enabled = false
}

data:extend({sink,sinkrecipe})
