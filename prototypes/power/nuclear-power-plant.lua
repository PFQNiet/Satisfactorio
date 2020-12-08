--[[ GENERATOR SHAPE
Total is 19x21
Boiler is 19x2
Generator is 19x19
]]

local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}

local name = "nuclear-power-plant"
local placeholder = {
	type = "constant-combinator",
	name = name,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {608,672}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {672,608}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {608,672}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {672,608}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-9.2,-10.2},{9.2,10.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = nil, -- mine either the boiler or the generator
	selection_box = {{-9.5,-10.5},{9.5,10.5}},
	selection_priority = 40
}
local boiler = {
	animation = empty_sprite,
	collision_box = {{-9.2,-0.7},{9.2,0.7}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "burner",
		fuel_category = "nuclear",
		fuel_inventory_size = 1
	},
	energy_usage = "2.5GW",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['boiler']['boiler'].working_sound,
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-on-map",
		"not-deconstructable",
		"not-blueprintable",
		"no-copy-paste"
	},
	fluid_boxes = {
		{
			base_area = 1,
			base_level = -1,
			filter = "water",
			pipe_connections = {
				{
					position = {0,1.5},
					type = "input"
				}
			},
			pipe_covers = table.deepcopy(data.raw.boiler.boiler.fluid_box.pipe_covers),
			production_type = "input"
		},
		{
			base_area = 1,
			base_level = 1,
			filter = "steam",
			pipe_connections = {
				{
					position = {0,-1.5},
					type = "output"
				}
			},
			pipe_covers = table.deepcopy(data.raw.boiler.boiler.fluid_box.pipe_covers),
			production_type = "output"
		}
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	placeable_by = {item=name,count=1},
	name = name.."-boiler",
	selection_box = {{-9.5,-1},{9.5,1}},
	type = "assembling-machine",
	crafting_speed = 1,
	crafting_categories = {"nuclear-power"},
	fixed_recipe = "nuclear-waste"
}
local accumulator = {
	picture = {
		filename = "__core__/graphics/empty.png",
		size = {1,1}
	},
	energy_source = {
		type = "electric",
		buffer_capacity = "1J",
		usage_priority = "tertiary"
	},
	charge_cooldown = 0,
	discharge_cooldown = 0,
	collision_box = {{-9.2,-9.2},{9.2,9.2}},
	flags = {
		"player-creation",
		"not-on-map",
		"not-deconstructable",
		"not-blueprintable",
		"no-copy-paste"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name.."-accumulator",
	selection_box = {{-9.5,-9.5},{9.5,9.5}},
	selection_priority = 30,
	type = "accumulator"
}
local generator_ne = {
	horizontal_animation = empty_sprite,
	vertical_animation = empty_sprite,
	collision_box = {{-9.2,-9.2},{9.2,9.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	effectivity = 1,
	maximum_temperature = 515,
	fluid_box = {
		base_area = 0.1,
		base_level = -1,
		filter = "steam",
		minimum_temperature = 515,
		pipe_connections = {
			{
				position = {0,10},
				type = "input"
			}
		},
		pipe_covers = table.deepcopy(data.raw.generator['steam-engine'].fluid_box.pipe_covers),
		production_type = "input"
	},
	fluid_usage_per_tick = 300/60/60,
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['reactor']['nuclear-reactor'].working_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"not-on-map",
		"not-deconstructable",
		"not-blueprintable",
		"no-copy-paste"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	placeable_by = {item=name,count=1},
	name = name.."-generator-ne",
	selection_box = {{-9.5,-9.5},{9.5,9.5}},
	type = "generator"
}
local generator_sw = table.deepcopy(generator_ne)
generator_sw.fluid_box.pipe_connections[1].position = {0,-10}
generator_sw.name = name.."-generator-sw"

local generatoritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-power",
	type = "item"
}

local ingredients = {
	{"concrete",150},
	{"heavy-modular-frame",10},
	{"supercomputer",5},
	{"copper-cable",50},
	{"advanced-circuit",15}
}
local generatorrecipe = {
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
local _group = data.raw['item-subgroup'][generatoritem.subgroup]
local generatorrecipe_undo = {
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
	order = _group.order .. "-" .. generatoritem.order,
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

data:extend({placeholder, boiler, accumulator, generator_ne, generator_sw, generatoritem, generatorrecipe, generatorrecipe_undo})
