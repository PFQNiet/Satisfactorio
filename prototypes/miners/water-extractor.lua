assert(foundation_layer ~= nil, "Foundation must be defined before water extractor, as it uses its collision mask")

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
	collision_mask = {"ground-tile","object-layer",foundation_layer},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "20MW",
	open_sound = data.raw['assembling-machine']['chemical-plant'].open_sound,
	close_sound = data.raw['assembling-machine']['chemical-plant'].close_sound,
	working_sound = data.raw['assembling-machine']['chemical-plant'].working_sound,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	flags = {
		"placeable-player",
		"player-creation"
	},
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
-- EEI type is used so that tooltip provides power info
local placeholder = {
	type = "electric-energy-interface",
	name = name.."-placeholder",
	energy_source = {
		type = "electric",
		buffer_capacity = "20MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "20MW",
	animations = extractor.animations,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	collision_mask = {"ground-tile","object-layer",foundation_layer},
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
	stack_size = 50,
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
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
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
