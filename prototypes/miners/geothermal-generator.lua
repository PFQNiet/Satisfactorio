local name = "geothermal-generator"
local miner = {
	animations = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name.."-mask.png",
		size = {288,288}
	},
	collision_box = {{-4.2,-4.2},{4.2,4.2}},
	collision_mask = {"item-layer","object-layer","player-layer"},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {type = "void"},
	energy_usage = "200MW",
	working_sound = data.raw['mining-drill']['pumpjack'].working_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"not-deconstructable"
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
	resource_categories = {"geothermal"},
	resource_searching_radius = 0.49,
	selection_box = {{-4.5,-4.5},{4.5,4.5}},
	type = "mining-drill",
	vector_to_place_result = {0,0}
}
local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	energy_source = {
		type = "electric",
		buffer_capacity = "200MJ",
		usage_priority = "primary-output",
		drain = "0W",
		input_flow_limit = "0W",
		output_flow_limit = "200MW"
	},
	energy_production = "200MW",
	animation = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {288,288}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-4.2,-4.2},{4.2,4.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"player-creation",
		"not-blueprintable",
		"no-copy-paste"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	selection_box = {{-4.5,-4.5},{4.5,4.5}}
}

local mineritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "e["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-power",
	type = "item"
}

local ingredients = {
	{"supercomputer",8},
	{"heavy-modular-frame",16},
	{"advanced-circuit",16},
	{"copper-plate",40},
	{"rubber",80}
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
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
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

data:extend({miner,interface,mineritem,minerrecipe,minerrecipe_undo})
