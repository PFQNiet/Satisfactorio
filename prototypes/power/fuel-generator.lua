-- Generator consists of a "fuel tank" and an electric interface

local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}

local name = "fuel-generator"

-- There IS an entity type for burning fuel, however it produces variable power for a fixed fluid consumption
-- This entity instead produces fixed power for a variable fluid consumption
local boiler = {
	animation = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {320,320}
	},
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	energy_source = {type = "void"}, -- the fluid is the fuel
	energy_usage = "150MW",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['assembling-machine']['oil-refinery'].working_sound,
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_boxes = {
		{
			base_area = 0.01,
			base_level = -1,
			pipe_connections = {
				{
					position = {0.5,-5.5},
					type = "input"
				}
			},
			pipe_covers = table.deepcopy(data.raw.boiler.boiler.fluid_box.pipe_covers),
			production_type = "input"
		},
		{
			base_area = 1.5,
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
	source_inventory_size = 0,
	result_inventory_size = 0,
	name = name,
	selection_box = {{-5,-5},{5,5}},
	selection_priority = 40,
	type = "furnace",
	crafting_speed = 1,
	crafting_categories = {"fuel-generator"}
}
local steaming1 = {
	name = name.."-fuel",
	type = "recipe",
	ingredients = {{type="fluid", name="fuel", amount=0.25}},
	results = {{type="fluid", name="energy", amount=150}},
	energy_required = 1,
	category = "fuel-generator",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}
local steaming2 = {
	name = name.."-biofuel",
	type = "recipe",
	ingredients = {{type="fluid", name="liquid-biofuel", amount=0.2}},
	results = {{type="fluid", name="energy", amount=150}},
	energy_required = 1,
	category = "fuel-generator",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}
local steaming3 = {
	name = name.."-turbofuel",
	type = "recipe",
	ingredients = {{type="fluid", name="turbofuel", amount=0.075}},
	results = {{type="fluid", name="energy", amount=150}},
	energy_required = 1,
	category = "fuel-generator",
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
		buffer_capacity = "150000001W",
		usage_priority = "secondary-output",
		drain = "0W"
	},
	energy_production = "150000001W", -- may be adjusted in case of low fuel
	pictures = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
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
	selection_box = {{-5,-5},{5,5}}
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
	picture = {
		filename = "__core__/graphics/empty.png",
		size = {1,1}
	},
	energy_source = {
		type = "electric",
		buffer_capacity = "1W",
		usage_priority = "secondary-input"
	},
	energy_usage = "1W",
	collision_box = interface.collision_box,
	flags = {
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	selection_box = interface.selection_box,
	selectable_in_game = false
}

local generatoritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-power",
	type = "item"
}

local ingredients = {
	{"computer",5},
	{"heavy-modular-frame",10},
	{"motor",15},
	{"rubber",50},
	{"quickwire",50}
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

data:extend({boiler, steaming1, steaming2, steaming3, interface, accumulator, generatoritem, generatorrecipe, generatorrecipe_undo})
