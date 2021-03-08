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
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = nil, -- mine either the boiler or the generator
	selection_box = {{-9.5,-10.5},{9.5,10.5}},
	selection_priority = 40
}
local boiler = {
	animation = {
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
	collision_box = {{-9.2,-10.2},{9.2,10.2}},
	energy_source = {
		type = "burner",
		fuel_category = "nuclear",
		fuel_inventory_size = 1,
		burnt_inventory_size = 1
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
	working_sound = data.raw['reactor']['nuclear-reactor'].working_sound,
	flags = {
		"not-on-map"
	},
	fluid_boxes = {
		{
			base_area = 0.1,
			base_level = -1,
			filter = "water",
			pipe_connections = {
				{
					position = {0,11},
					type = "input"
				}
			},
			pipe_covers = table.deepcopy(data.raw.boiler.boiler.fluid_box.pipe_covers),
			production_type = "input"
		},
		{
			base_area = 25,
			base_level = 1,
			filter = "energy",
			pipe_connections = {},
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
	name = name,
	selection_box = {{-9.5,-10.5},{9.5,10.5}},
	type = "assembling-machine",
	crafting_speed = 1,
	crafting_categories = {"nuclear-power"},
	fixed_recipe = name.."-steam"
}
local steaming = {
	name = name.."-steam",
	localised_description = {"recipe-description.nuclear-power"},
	type = "recipe",
	ingredients = {{type="fluid", name="water", amount=5}},
	results = {
		{type="fluid", name="energy", amount=2500},
		{type="item", name="nuclear-waste", amount=0, probability=0} -- managed manually by script
	},
	main_product = "nuclear-waste",
	energy_required = 1,
	category = "nuclear-power",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}
local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	localised_name = {"entity-name."..name},
	localised_description = {"entity-description."..name},
	energy_source = {
		type = "electric",
		buffer_capacity = "2.5GW",
		usage_priority = "secondary-output",
		drain = "0W"
	},
	energy_production = "2.5GW", -- may be adjusted in case of low fuel
	pictures = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-9.2,-10.2},{9.2,10.2}},
	flags = {
		"not-on-map"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	open_sound = boiler.open_sound,
	close_sound = boiler.close_sound,
	placeable_by = {item=name,count=1},
	selection_box = {{-9.5,-10.5},{9.5,10.5}}
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
	collision_box = {{-9.2,-10.2},{9.2,10.2}},
	flags = {
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name.."-accumulator",
	selection_box = {{-9.5,-10.5},{9.5,10.5}},
	selection_priority = 30,
	type = "accumulator"
}

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
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
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

data:extend({boiler, steaming, interface, accumulator, generatoritem, generatorrecipe, generatorrecipe_undo})
