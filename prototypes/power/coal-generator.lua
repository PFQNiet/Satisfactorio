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
local boiler = {
	animation = {
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
	collision_box = {{-2.2,-5.7},{2.2,5.7}},
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
	working_sound = data.raw['generator']['steam-engine'].working_sound,
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_boxes = {
		{
			base_area = 0.05,
			base_level = -1,
			filter = "water",
			pipe_connections = {
				{
					position = {-1,6.5},
					type = "input"
				}
			},
			pipe_covers = table.deepcopy(data.raw.boiler.boiler.fluid_box.pipe_covers),
			production_type = "input"
		}
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	name = name,
	selection_box = {{-2.5,-6},{2.5,6}},
	type = "assembling-machine",
	crafting_speed = 1,
	crafting_categories = {"coal-generator"},
	fixed_recipe = name.."-steam"
}
local steaming = {
	name = name.."-steam",
	type = "recipe",
	localised_name = {"recipe-name."..name.."-steam"},
	localised_description = {"recipe-description."..name.."-steam"},
	icon = "__Satisfactorio__/graphics/icons/power.png",
	icon_size = 64,
	subgroup = "fluid-fuel",
	ingredients = {{type="fluid", name="water", amount=0.75}},
	results = {},
	energy_required = 1,
	category = "coal-generator",
	show_amount_in_title = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}
local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	localised_name = {"entity-name."..name},
	energy_source = {
		type = "electric",
		buffer_capacity = "75000001W",
		usage_priority = "primary-output",
		drain = "0W"
	},
	energy_production = "75000001W", -- may be adjusted in case of low fuel
	pictures = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.2,-5.7},{2.2,5.7}},
	collision_mask = {},
	flags = {
		"not-on-map"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	open_sound = boiler.open_sound,
	close_sound = boiler.close_sound,
	placeable_by = {item=name,count=1},
	selection_box = {{-2.5,-6},{2.5,6}},
	selectable_in_game = false
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
	localised_name = {"entity-name.generator-buffer",{"entity-name."..name}},
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
	collision_mask = {},
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
	order = "b["..name.."]",
	place_result = name,
	stack_size = 50,
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