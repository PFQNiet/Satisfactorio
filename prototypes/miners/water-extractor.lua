local name = "water-extractor"
local extractor = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animations = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {320,320}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {320,320}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {320,320}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {320,320}
		}
	},
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	collision_mask = {"ground-tile","object-layer","layer-12"}, -- "layer-12" is the Foundation layer - you can't build Foundation under an extractor
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "20MW",
	working_sound = data.raw['assembling-machine']['chemical-plant'].working_sound,
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
	placeable_by = {item=name,count=1},
	mining_speed = 2, -- base 120/min
	name = name,
	resource_categories = {"water"},
	resource_searching_radius = 1.99,
	selection_box = {{-5,-5},{5,5}},
	type = "mining-drill",
	vector_to_place_result = {0,0},
	output_fluid_box = {
		base_area = 0.1,
		base_level = 1,
		pipe_connections = {
			{positions = {
				{0.5,-5.5},
				{5.5,0.5},
				{-0.5,5.5},
				{-5.5,-0.5}
			}}
		},
		pipe_covers = data.raw['mining-drill']['pumpjack'].output_fluid_box.pipe_covers
	}
}
-- "placeholder" that can be placed on any water tiles, will spawn a water "resource node" beneath itself
local placeholder = {
	type = "constant-combinator",
	name = name.."-placeholder",
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = {
		filename = "__core__/graphics/empty.png",
		width = 1,
		height = 1
	},
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = extractor.animations,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	collision_mask = {"ground-tile","object-layer","layer-12"},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = nil, -- auto-removed on placement of the extractor
	selection_box = {{-5,-5},{5,5}}
}

local extractoritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name.."-placeholder",
	stack_size = 1,
	subgroup = "production-fluid",
	type = "item"
}

local ingredients = {
	{"copper-plate",20},
	{"reinforced-iron-plate",10},
	{"rotor",10}
}
local extractorrecipe = {
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
local _group = data.raw['item-subgroup'][extractoritem.subgroup]
local extractorrecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. extractoritem.order,
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

data:extend({extractor,placeholder,extractoritem,extractorrecipe,extractorrecipe_undo})