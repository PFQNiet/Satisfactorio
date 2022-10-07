local placeholder = require("graphics.placeholders.builder")

-- base entity is an electric-energy-interface to manage power consumption
-- station itself is a trio of storage chests: one with a single slot and single input for fuel, one with 18 slots and an input, one with 18 slots and an output
-- building itself is 12x12 so the layout can be |--F----I-O--|

local name = "drone-port"
local sounds = copySoundsFrom(data.raw.roboport.roboport)
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
	pictures = placeholder().fourway().addBox(-5.5,-5.5,12,12,{{-3.5,5.5},{1.5,5.5}},{{3.5,5.5}}).addIcon(graphics.."icons/"..name..".png",96).addFuelMark{-3.5,5}.result(),
	max_health = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-5.7,-5.7},{5.7,5.7}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	working_sound = sounds.working_sound,
	selection_box = {{-6,-6},{6,6}}
}

-- invisible train stop placed on the drone port to provide a label and clickable access point on the map
sounds = copySoundsFrom(data.raw["train-stop"]["train-stop"])
local stop = {
	type = "train-stop",
	name = name.."-stop",
	localised_name = {"entity-name."..name},
	icon = base.icon,
	icon_size = base.icon_size,
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selectable_in_game = false,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {},
	flags = {"placeable-neutral", "player-creation", "filter-directions"},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	max_health = 1,
	animation_ticks_per_frame = 20
}

sounds = copySoundsFrom(data.raw.container["steel-chest"])
local storage = {
	type = "container",
	name = name.."-box",
	localised_name = {"entity-name."..name},
	icon = base.icon,
	icon_size = base.icon_size,
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	selectable_in_game = false,
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	collision_mask = {},
	flags = {"not-on-map"},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	inventory_size = 18,
	enable_inventory_bar = false,
	max_health = 1,
	picture = empty_graphic,
	scale_info_icons = true
}

sounds = copySoundsFrom(data.raw.container["wooden-chest"])
local fuelbox = {
	type = "container",
	name = name.."-fuelbox",
	icon = base.icon,
	icon_size = base.icon_size,
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selectable_in_game = false,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {},
	flags = {"not-on-map"},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	inventory_size = 1,
	enable_inventory_bar = false,
	max_health = 1,
	picture = empty_graphic
}

local stationitem = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "u-a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "transport",
	type = "item"
}

local stationrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"heavy-modular-frame",20},
		{"high-speed-connector",20},
		{"alclad-aluminium-sheet",50},
		{"aluminium-casing",50},
		{"radio-control-unit",10}
	},
	result = name
}

data:extend{base,stop,storage,fuelbox,stationitem,stationrecipe}
