local name = "biomass"
local item = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "f["..name.."]",
	stack_size = 200,
	fuel_category = "chemical",
	fuel_value = "180MJ"
}
data:extend{item}

local ingredient = "leaves"
local recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "f["..name.."]-a["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/biomass.png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,10}
	},
	result = name,
	result_count = 5,
	energy_required = 5,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 1)
data:extend{recipe}

ingredient = "wood"
recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "f["..name.."]-b["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/biomass.png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,4}
	},
	result = name,
	result_count = 20,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)
data:extend{recipe}

ingredient = "mycelia"
recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "f["..name.."]-c["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/biomass.png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,10}
	},
	result = name,
	result_count = 10,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 1)
data:extend{recipe}

ingredient = "alien-protein"
recipe = {
	name = name.."-from-"..ingredient,
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredient}},
	type = "recipe",
	order = "f["..name.."]-d["..ingredient.."]",
	icons = {
		{ icon = graphics.."icons/biomass.png", icon_size = 64 },
		{ icon = graphics.."icons/"..ingredient..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = {
		{ingredient,1}
	},
	result = name,
	result_count = 100,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 2)
data:extend{recipe}
