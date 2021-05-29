local name = "oil-extractor"
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
	energy_usage = "40MW",
	open_sound = data.raw['mining-drill']['pumpjack'].open_sound,
	close_sound = data.raw['mining-drill']['pumpjack'].close_sound,
	working_sound = data.raw['mining-drill']['pumpjack'].working_sound,
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
	mining_speed = 1, -- base 120/min
	name = name,
	resource_categories = {"crude-oil"},
	resource_searching_radius = 1.49,
	selection_box = {{-2.5,-6.5},{2.5,2.5}},
	type = "mining-drill",
	vector_to_place_result = {0,0},
	output_fluid_box = {
		base_area = 0.1,
		base_level = 1,
		pipe_connections = {
			{positions = {
				{0,-7},
				{7,0},
				{0,7},
				{-7,0}
			}}
		},
		pipe_covers = data.raw['mining-drill']['pumpjack'].output_fluid_box.pipe_covers
	}
}

local mineritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-fluid",
	type = "item"
}

local ingredients = {
	{"motor",15},
	{"encased-industrial-beam",20},
	{"copper-cable",60}
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

data:extend({miner,mineritem,minerrecipe,minerrecipe_undo})
