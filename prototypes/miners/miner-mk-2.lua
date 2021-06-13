local name = "miner-mk-2"
local miner = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animations = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {160,288},
			shift = {0,-2}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {288,160},
			shift = {2,0}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {160,288},
			shift = {0,2}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {288,160},
			shift = {-2,0}
		}
	},
	collision_box = {{-2.2,-6.2},{2.2,2.2}},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "12MW",
	open_sound = data.raw['mining-drill']['electric-mining-drill'].open_sound,
	close_sound = data.raw['mining-drill']['electric-mining-drill'].close_sound,
	working_sound = data.raw['mining-drill']['electric-mining-drill'].working_sound,
	flags = {
		"placeable-player",
		"player-creation"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	mining_speed = 1, -- base 60/min
	name = name,
	resource_categories = {"solid"},
	resource_searching_radius = 1.49,
	selection_box = {{-2.5,-6.5},{2.5,2.5}},
	type = "mining-drill",
	fast_replaceable_group = "miner",
	next_upgrade = "miner-mk-3",
	vector_to_place_result = {0,0}
}

local minerbox = {
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	collision_mask = {},
	enable_inventory_bar = false,
	flags = {
		"not-on-map"
	},
	icon = miner.icon,
	icon_size = miner.icon_size,
	inventory_size = 1,
	max_health = 1,
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	minable = {
		mining_time = 1,
		result = name,
	},
	name = name.."-box",
	picture = data.raw.container['steel-chest'].picture,
	placeable_by = {item=name,count=1},
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	selection_priority = 60,
	selectable_in_game = false,
	type = "container"
}

local mineritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "production-miner",
	type = "item"
}

local ingredients = {
	{"portable-miner",2},
	{"encased-industrial-beam",10},
	{"steel-pipe",20},
	{"modular-frame",10}
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
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
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
