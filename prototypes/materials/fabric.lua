local name = "fabric"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "m[mycelia]-a["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"mycelia",1},
		{"biomass",5}
	},
	result = name,
	energy_required = 4,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 2)

local autorecipe = {
	name = "polyester-fabric",
	order = item.order.."-auto",
	type = "recipe",
	ingredients = {
		{"polymer-resin",1},
		{type="fluid",name="water",amount=1}
	},
	result = name,
	energy_required = 2,
	category = "refining",
	enabled = false
}

data:extend{item,recipe,autorecipe}
