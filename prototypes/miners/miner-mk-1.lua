local name = "miner-mk-1"
local miner = {
	allowed_effects = {"speed","consumption"},
	animations = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {160,288},
			shift = {0,-2}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {288,160},
			shift = {2,0}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {160,288},
			shift = {0,2}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {288,160},
			shift = {-2,0}
		}
	},
	collision_box = {{-2.3,-6.3},{2.3,2.3}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "5MW",
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
	mining_speed = 1/2, -- base 30/min
	name = name,
	resource_categories = {"solid"},
	resource_searching_radius = 0.49,
	selection_box = {{-2.5,-6.5},{2.5,2.5}},
	type = "mining-drill",
	vector_to_place_result = {0,0}
}

local minerbox = {
	collision_box = {{-1.3,-1.3},{1.3,1.3}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	enable_inventory_bar = false,
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-blueprintable",
		"no-copy-paste"
	},
	icon = miner.icon,
	icon_size = miner.icon_size,
	inventory_size = 1,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name,
	},
	name = name.."-box",
	picture = data.raw.container['steel-chest'].picture,
	placeable_by = {item=name,count=1},
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	selection_priority = 60,
	type = "container"
}

local mineritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-miner",
	type = "item"
}

local ingredients = {
	{"portable-miner",1},
	{"iron-plate",10},
	{"concrete",10}
}
local minerrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][mineritem.subgroup]
local minerrecipe_undo = {
	name = name.."-undo",
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. mineritem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({miner,minerbox,mineritem,minerrecipe,minerrecipe_undo})