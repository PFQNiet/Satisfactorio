local name = "smokeless-powder"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "j[sulfur]-b["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"black-powder",2},
		{type="fluid",name="heavy-oil",amount=1}
	},
	result = name,
	result_count = 2,
	energy_required = 6,
	category = "refining",
	enabled = false
}

data:extend{item,recipe}
