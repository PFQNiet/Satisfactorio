local name = "blender"
local pipe_covers = data.raw['mining-drill']['pumpjack'].output_fluid_box.pipe_covers
local blender = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {288,256}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {256,288}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {288,256}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {256,288}
		}
	},
	collision_box = {{-4.2,-3.7},{4.2,3.7}},
	crafting_categories = {"blending"},
	crafting_speed = 1,
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "75MW",
	fluid_boxes = {
		{
			base_area = 0.1,
			base_level = -1,
			production_type = "input",
			pipe_connections = {{
				type = "input",
				position = {1,4.5}
			}},
			pipe_covers = pipe_covers
		},
		{
			base_area = 0.1,
			base_level = -1,
			production_type = "input",
			pipe_connections = {{
				type = "input",
				position = {3,4.5}
			}},
			pipe_covers = pipe_covers
		},
		{
			base_area = 0.5,
			base_level = 1,
			production_type = "output",
			pipe_connections = {{
				type = "output",
				position = {3,-4.5}
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
	selection_box = {{-4.5,-4},{4.5,4}},
	type = "assembling-machine"
}

local blenderitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "e["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "production-manufacturer",
	type = "item"
}

local ingredients = {
	{"motor",20},
	{"heavy-modular-frame",10},
	{"aluminium-casing",50},
	{"radio-control-unit",5}
}
local blenderrecipe = {
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
local _group = data.raw['item-subgroup'][blenderitem.subgroup]
local blenderrecipe_undo = {
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
	order = _group.order .. "-" .. blenderitem.order,
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

data:extend({blender,blenderitem,blenderrecipe,blenderrecipe_undo})
