--[[ GENERATOR SHAPE
Total is 5x12
Boiler is 5x4
Generator is 5x8
]]

local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}

local name = "coal-generator"
local placeholder = {
	type = "constant-combinator",
	name = name,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = {
		filename = "__core__/graphics/empty.png",
		width = 1,
		height = 1
	},
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {160,384}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {384,160}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {160,384}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {384,160}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.2,-5.7},{2.2,5.7}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = nil, -- mine either the boiler or the generator
	selection_box = {{-2.5,-6},{2.5,6}},
	selection_priority = 40
}
local boiler = {
	animation = empty_sprite,
	collision_box = {{-2.2,-1.7},{2.2,1.7}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "burner",
		fuel_category = "carbon",
		fuel_inventory_size = 1
	},
	energy_usage = "75MW",
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
		"not-blueprintable",
		"no-copy-paste"
	},
	fluid_boxes = {
		{
			base_area = 0.1,
			base_level = -1,
			filter = "water",
			pipe_connections = {
				{
					position = {-1,2.5},
					type = "input"
				}
			},
			pipe_covers = table.deepcopy(data.raw.boiler.boiler.fluid_box.pipe_covers),
			production_type = "input"
		},
		{
			base_area = 0.1,
			base_level = 1,
			filter = "steam",
			pipe_connections = {
				{
					position = {0,-2.5},
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
	selection_box = {{-2.5,-2},{2.5,2}},
	type = "assembling-machine",
	crafting_speed = 0.75,
	crafting_categories = {"coal-generator"},
	fixed_recipe = name.."-steam"
}
local steaming = {
	name = name.."-steam",
	type = "recipe",
	ingredients = {{type="fluid", name="water", amount=1}},
	results = {{type="fluid", name="steam", amount=1, temperature=115}},
	energy_required = 1,
	category = "coal-generator",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true,
	hide_from_stats = true
}
local accumulator_ns = {
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
	collision_box = {{-2.2,-3.7},{2.2,3.7}},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name.."-accumulator-ns",
	selection_box = {{-2.5,-4},{2.5,4}},
	selection_priority = 30,
	type = "accumulator"
}
local accumulator_ew = {
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
	collision_box = {{-3.7,-2.2},{3.7,2.2}},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name.."-accumulator-ew",
	selection_box = {{-4,-2.5},{4,2.5}},
	selection_priority = 30,
	type = "accumulator"
}
local generator_ne = {
	horizontal_animation = empty_sprite,
	vertical_animation = empty_sprite,
	collision_box = {{-2.2,-3.7},{2.2,3.7}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	effectivity = 1,
	maximum_temperature = 115,
	fluid_box = {
		base_area = 0.1,
		base_level = -1,
		filter = "steam",
		minimum_temperature = 100,
		pipe_connections = {
			{
				position = {0,4.5},
				type = "input"
			}
		},
		pipe_covers = table.deepcopy(data.raw.generator['steam-engine'].fluid_box.pipe_covers),
		production_type = "input"
	},
	fluid_usage_per_tick = 45/60/60,
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['generator']['steam-engine'].working_sound,
	flags = {
		"placeable-player",
		"player-creation",
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
	selection_box = {{-2.5,-4},{2.5,4}},
	type = "generator"
}
local generator_sw = table.deepcopy(generator_ne)
generator_sw.fluid_box.pipe_connections[1].position = {0,-4.5}
generator_sw.name = name.."-generator-sw"

local generatoritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-power",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",20},
	{"rotor",10},
	{"copper-cable",30}
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

data:extend({placeholder, boiler, steaming, accumulator_ns, accumulator_ew, generator_ne, generator_sw, generatoritem, generatorrecipe, generatorrecipe_undo})
