-- base entity is an electric-energy-interface to manage power consumption
-- station itself is a trio of storage chests: one with a single slot and single input for fuel, one with 18 slots and an input, one with 18 slots and an output
-- building itself is 12x12 so the layout can be |--F----I-O--|

local name = "drone-port"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "100MW",
		input_flow_limit = "100MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "100MW",
	pictures = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {384,384}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {384,384}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {384,384}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {384,384}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-5.7,-5.7},{5.7,5.7}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	open_sound = data.raw.roboport.roboport.open_sound,
	close_sound = data.raw.roboport.roboport.close_sound,
	selection_box = {{-6,-6},{6,6}},
	selection_priority = 40
}

local storage = {
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	enable_inventory_bar = false,
	flags = {
		"not-on-map"
	},
	open_sound = {
		filename = "__base__/sound/metallic-chest-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/metallic-chest-close.ogg",
		volume = 0.5
	},
	icon = base.icon,
	icon_size = base.icon_size,
	inventory_size = 18,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name.."-box",
	picture = empty_sprite,
	placeable_by = {item=name,count=1},
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	type = "container"
}
local fuelbox = {
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	enable_inventory_bar = false,
	flags = {
		"not-on-map"
	},
	open_sound = {
		filename = "__base__/sound/wooden-chest-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/wooden-chest-close.ogg",
		volume = 0.5
	},
	icon = base.icon,
	icon_size = base.icon_size,
	inventory_size = 1,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name.."-fuelbox",
	picture = empty_sprite,
	placeable_by = {item=name,count=1},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	type = "container"
}

local stationitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "u-a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "transport",
	type = "item"
}

local ingredients = {
	{"heavy-modular-frame",20},
	{"advanced-circuit",20},
	{"alclad-aluminium-sheet",50},
	{"aluminium-casing",50},
	{"radio-control-unit",10}
}
local stationrecipe = {
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
local _group = data.raw['item-subgroup'][stationitem.subgroup]
local stationrecipe_undo = {
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
	order = _group.order .. "-" .. stationitem.order,
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

data:extend({base,storage,fuelbox,stationitem,stationrecipe,stationrecipe_undo})
