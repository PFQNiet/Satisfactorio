local name = "pressure-conversion-cube"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[frame]-d["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"fused-modular-frame",1},
		{"radio-control-unit",2}
	},
	result = name,
	energy_required = 60,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 12)

data:extend{item,recipe}
