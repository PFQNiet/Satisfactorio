local name = "alien-protein"
local item = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "r[remains]-p["..name.."]",
	stack_size = 100
}
data:extend{item}

local ingredient = "hog-remains"
local recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "r["..name.."]-a["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/"..name..".png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,1}
	},
	result = name,
	energy_required = 3,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)
data:extend{recipe}

ingredient = "plasma-spitter-remains"
recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "r["..name.."]-b["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/"..name..".png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,1}
	},
	result = name,
	energy_required = 3,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)
data:extend{recipe}

ingredient = "hatcher-remains"
recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "r["..name.."]-c["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/"..name..".png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,1}
	},
	result = name,
	energy_required = 3,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)
data:extend{recipe}

ingredient = "stinger-remains"
recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "r["..name.."]-d["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/"..name..".png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,1}
	},
	result = name,
	energy_required = 3,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)
data:extend{recipe}
