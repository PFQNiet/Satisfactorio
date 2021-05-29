local name = "resource-well-pressuriser"
local miner = {
	animations = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {96,96}
	},
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	energy_source = {type = "void"},
	energy_usage = "15MW",
	working_sound = data.raw['mining-drill']['pumpjack'].working_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"not-rotatable"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	mining_speed = 1,
	name = name,
	resource_categories = {"resource-node"},
	resource_searching_radius = 0.49,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	type = "mining-drill",
	vector_to_place_result = {0,0},
	output_fluid_box = {
		base_area = 0.1,
		base_level = 1,
		pipe_connections = {
			{positions = {
				{0,-2},
				{2,0},
				{0,2},
				{-2,0}
			}}
		},
		pipe_covers = data.raw['mining-drill']['pumpjack'].output_fluid_box.pipe_covers
	}
}

local ingredients = {
	{"steel-plate",10},
	{"plastic-bar",10}
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
