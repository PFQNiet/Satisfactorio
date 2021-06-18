assert(train_platform_layer ~= nil, "Train station must be defined before freight platform, as it uses its collision mask")

local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local name = "fluid-freight-platform"
local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "50MW",
		input_flow_limit = "50MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "50MW",
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

local walkable = {
	type = "constant-combinator",
	name = name.."-walkable",
	localised_name = {"entity-name."..name},
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
	selectable_in_game = false
}
local collision = {
	type = "constant-combinator",
	name = name.."-collision",
	localised_name = {"entity-name."..name},
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.7,-3.2},{2.7,3.2}},
	flags = {
		"placeable-off-grid"
	},
	minable = nil,
	selection_box = {{-3,-3.5},{3,3.5}},
	selectable_in_game = false
}

local storage = {
	type = "storage-tank",
	name = name.."-tank",
	localised_name = {"entity-name."..name},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	collision_mask = {},
	flags = {
		"not-on-map"
	},
	fluid_box = {
		height = data.raw.pipe.pipe.fluid_box.height,
		base_area = 24/data.raw.pipe.pipe.fluid_box.height, -- 2400 capacity
		pipe_connections = {
			{position={3,-2},type="output"},
			{position={3,-1},type="input"},
			{position={3,1},type="input"},
			{position={3,2},type="output"}
		},
		pipe_covers = table.deepcopy(data.raw['storage-tank']['storage-tank'].fluid_box.pipe_covers)
	},
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	flow_length_in_ticks = 360,
	pictures = {
		window_background = data.raw['storage-tank']['storage-tank'].pictures.window_background,
		fluid_background = data.raw['storage-tank']['storage-tank'].pictures.fluid_background,
		flow_sprite = data.raw['storage-tank']['storage-tank'].pictures.flow_sprite,
		gas_flow = data.raw['storage-tank']['storage-tank'].pictures.gas_flow,
		picture = empty_sprite
	},
	placeable_by = {item=name,count=1},
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	selectable_in_game = false,
	two_direction_only = false,
	window_bounding_box = {{-0.125,0.6875},{0.1875,1.1875}},
	working_sound = data.raw['storage-tank']['storage-tank'].working_sound
}

local item = {
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	name = name,
	order = "a[train-system]-b[platforms]-c["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "train-transport",
	type = "item"
}

local ingredients = {
	{"heavy-modular-frame",6},
	{"computer",2},
	{"concrete",50},
	{"copper-cable",25},
	{"motor",5}
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
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	enabled = false
}

data:extend({base,walkable,collision,storage,item,recipe,recipe_undo})
