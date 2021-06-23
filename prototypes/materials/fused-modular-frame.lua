local name = "fused-modular-frame"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[frame]-c["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"heavy-modular-frame",1},
		{"aluminium-casing",50},
		{type="fluid", name="nitrogen-gas", amount=25}
	},
	result = name,
	energy_required = 40,
	category = "blending",
	enabled = false
}

data:extend{item,recipe}
