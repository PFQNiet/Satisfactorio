local name = "plastic"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f[oil]-a["..name.."]",
	stack_size = 200,
	subgroup = "parts",
	type = "item"
}

local recipe1 = {
	name = name,
	type = "recipe",
	ingredients = {
		{type="fluid",name="crude-oil",amount=3}
	},
	results = {
		{name,2},
		{type="fluid",name="heavy-oil",amount=1}
	},
	main_product = name,
	energy_required = 6,
	category = "refining",
	order = item.order.."-a",
	enabled = false
}
local recipe2 = {
	name = "residual-"..name,
	localised_name = {"recipe-name.residual-"..name},
	type = "recipe",
	ingredients = {
		{"polymer-resin",6},
		{type="fluid",name="water",amount=2}
	},
	results = {{name,2}},
	energy_required = 6,
	category = "refining",
	icons = {
		{ icon = graphics.."icons/"..name..".png", icon_size = 64 },
		{ icon = graphics.."icons/polymer-resin.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	order = item.order.."-b",
	allow_decomposition = false,
	enabled = false
}

data:extend{item,recipe1,recipe2}
