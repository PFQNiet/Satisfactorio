assert(train_platform_layer ~= nil, "Train station must be defined before freight platform, as it uses its collision mask")

local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local name = "empty-platform"
local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "0J",
		usage_priority = "secondary-input",
		drain = "0W",
		input_flow_limit = "0W",
		output_flow_limit = "0W",
		render_no_power_icon = false,
		render_no_network_icon = false
	},
	pictures = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {448,224}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {224,448}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {448,224}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {224,448}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	render_layer = "lower-object",
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
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
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
	order = "a[train-system]-b[platforms]-d["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "train-transport",
	type = "item"
}

local ingredients = {
	{"heavy-modular-frame",6},
	{"concrete",50}
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
