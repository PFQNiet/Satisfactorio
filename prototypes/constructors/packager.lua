local name = "packager"
local pipe_covers = data.raw['mining-drill']['pumpjack'].output_fluid_box.pipe_covers
local packager = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {160,160}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {160,160}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {160,160}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {160,160}
		}
	},
	collision_box = {{-2.21,-2.2},{2.21,2.2}},
	crafting_categories = {"packaging"},
	crafting_speed = 1,
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "10MW",
	fluid_boxes = {
		{
			base_area = 0.1,
			base_level = -1,
			production_type = "input",
			pipe_connections = {{
				type = "input",
				position = {-1,3}
			}},
			pipe_covers = pipe_covers
		},
		{
			base_area = 0.5,
			base_level = 1,
			production_type = "output",
			pipe_connections = {{
				type = "output",
				position = {-1,-3}
			}},
			pipe_covers = pipe_covers
		}
	},
	open_sound = data.raw['assembling-machine']['centrifuge'].open_sound,
	close_sound = data.raw['assembling-machine']['centrifuge'].close_sound,
	working_sound = data.raw['assembling-machine']['centrifuge'].working_sound,
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
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	type = "assembling-machine"
}

local packageritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "e["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-manufacturer",
	type = "item"
}

local ingredients = {
	{"steel-plate",20},
	{"rubber",10},
	{"plastic-bar",10}
}
local packagerrecipe = {
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
local _group = data.raw['item-subgroup'][packageritem.subgroup]
local packagerrecipe_undo = {
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
	order = _group.order .. "-" .. packageritem.order,
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

data:extend({packager,packageritem,packagerrecipe,packagerrecipe_undo})
