local name = "particle-accelerator"
local pipe_covers = data.raw['mining-drill']['pumpjack'].output_fluid_box.pipe_covers
local accelerator = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {608,384}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {384,608}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {608,384}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {384,608}
		}
	},
	collision_box = {{-9.2,-5.7},{9.2,5.7}},
	crafting_categories = {"accelerating"},
	crafting_speed = 1,
	energy_source = {
		type = "void"
	},
	energy_usage = "1500MW",
	fluid_boxes = {
		{
			base_area = 0.1,
			base_level = -1,
			production_type = "input",
			pipe_connections = {{
				type = "input",
				position = {-4,6.5}
			}},
			pipe_covers = pipe_covers
		}
	},
	open_sound = data.raw['lab']['lab'].open_sound,
	close_sound = data.raw['lab']['lab'].close_sound,
	working_sound = data.raw['lab']['lab'].working_sound,
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
	name = name,
	selection_box = {{-9.5,-6},{9.5,6}},
	type = "assembling-machine"
}
local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	localised_name = {"entity-name."..name},
	localised_description = {"entity-description."..name},
	energy_source = {
		type = "electric",
		buffer_capacity = "1500MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "1500MW", -- adjusted based on recipe
	pictures = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-9.2,-5.7},{9.2,5.7}},
	collision_mask = {},
	flags = {
		"not-on-map"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	open_sound = accelerator.open_sound,
	close_sound = accelerator.close_sound,
	placeable_by = {item=name,count=1},
	selection_box = {{-9.5,-6},{9.5,6}}
}

local acceleratoritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "production-manufacturer",
	type = "item"
}

local ingredients = {
	{"radio-control-unit",25},
	{"electromagnetic-control-rod",100},
	{"supercomputer",10},
	{"cooling-system",50},
	{"fused-modular-frame",20},
	{"turbo-motor",10}
}
local acceleratorrecipe = {
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
local _group = data.raw['item-subgroup'][acceleratoritem.subgroup]
local acceleratorrecipe_undo = {
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
	order = _group.order .. "-" .. acceleratoritem.order,
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

data:extend({accelerator,interface,acceleratoritem,acceleratorrecipe,acceleratorrecipe_undo})
