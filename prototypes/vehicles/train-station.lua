-- base entity is an electric-energy-interface to manage power consumption
-- station is 7x14 and auto-builds (and removes) a vanilla train-stop entity
-- freight platform layout is |OI-IO|
-- fluid platform consists of pumps and a storage tank, so that it can draw fluid into itself and output it
-- central 7x2 is reserved for the rails
train_platform_layer = require("collision-mask-util").get_first_unused_layer()

local name = "train-station"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local stop = data.raw.item['train-stop']
stop.place_result = nil
stop = data.raw['train-stop']['train-stop']
stop.minable = {
	mining_time = 1,
	result = name
}
stop.placeable_by = {{item=name,count=1}}
stop.max_health = 1
stop.selection_priority = 45

local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "50MW",
		usage_priority = "secondary-input",
		drain = "0W",
		output_flow_limit = "0W"
	},
	energy_usage = "50MW", -- initial value, which gets increased when pulling trains
	pictures = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {448,224}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {224,448}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {448,224}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {224,448}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	render_layer = "decorative", -- required so that the train-stop renders on top of it
	collision_box = {{-6.7,-3.2},{6.7,3.2}},
	collision_mask = {train_platform_layer},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	remove_decoratives = "true",
	open_sound = stop.open_sound,
	close_sound = stop.close_sound,
	selection_box = {{-7,-3.5},{7,3.5}},
	selection_priority = 40
}

local collision = {
	type = "constant-combinator",
	name = name.."-walkable",
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.7,-3.2},{2.7,3.2}},
	collision_mask = {"object-layer", "floor-layer", "water-tile"},
	flags = {
		"placeable-off-grid"
	},
	minable = nil,
	selection_box = {{-3,-3.5},{3,3.5}},
	selection_priority = 30
}

local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[train-system]-b[platforms]-a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "train-transport",
	type = "item"
}

local ingredients = {
	{"heavy-modular-frame",4},
	{"computer",8},
	{"concrete",50},
	{"copper-cable",25}
}
local recipe = {
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
local _group = data.raw['item-subgroup'][item.subgroup]
local recipe_undo = {
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
	order = _group.order .. "-" .. item.order,
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

data:extend({base,collision,item,recipe,recipe_undo})
