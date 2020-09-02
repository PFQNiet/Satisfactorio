local name = "portable-miner"
-- mining speed is 2/3 that of electric miner
local pm = {
	allowed_effects = {},
	animations = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {32,32}
	},
	collision_box = {{-0.35,-0.35},{0.35,0.35}},
	corpse = "small-remnants",
	dying_explosion = "explosion",
	energy_source = {type="void"},
	energy_usage = "1W",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"not-deconstructable"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = nil, -- not minable - mine the box instead
	mining_speed = 1/3, -- base 20/min
	name = name,
	resource_categories = {"basic-solid"},
	resource_searching_radius = 0.49,
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	type = "mining-drill",
	vector_to_place_result = {0,0} -- may need to be {0,-0.01}
}

local pmbox = {
	collision_box = {{-0.35,-0.35},{0.35,0.35}},
	corpse = "small-remnants",
	dying_explosion = "explosion",
	enable_inventory_bar = false,
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-blueprintable",
		"no-automated-item-removal",
		"no-copy-paste"
	},
	icon = pm.icon,
	icon_size = pm.icon_size,
	inventory_size = 1,
	max_health = 1,
	minable = {
		mining_time = 0.25,
		result = name,
	},
	name = name.."-box",
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {32,32}
	},
	placeable_by = {item=name,count=1},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selection_priority = 60,
	type = "container"
}

local pmitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-miner",
	type = "item"
}

local ingredients = {
	{"iron-plate",2},
	{"iron-stick",4}
}
local pmrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 10/4,
	category = "equipment",
	hide_from_stats = true
}

data:extend({pm,pmbox,pmitem,pmrecipe})