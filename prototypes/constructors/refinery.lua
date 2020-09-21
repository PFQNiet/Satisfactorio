local name = "refinery"
local pipe_covers = data.raw['mining-drill']['pumpjack'].output_fluid_box.pipe_covers
local refinery = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {160,320}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {320,160}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {160,320}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {320,160}
		}
	},
	collision_box = {{-2.2,-4.7},{2.2,4.7}},
	corpse = "big-remnants",
	crafting_categories = {"refining"},
	crafting_speed = 1,
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "30MW",
	fluid_boxes = {
		{
			base_area = 0.1,
			base_level = -1,
			production_type = "input",
			pipe_connections = {{
				type = "input",
				position = {-1,5.5}
			}},
			pipe_covers = pipe_covers
		},
		{
			base_area = 0.5,
			base_level = 1,
			production_type = "output",
			pipe_connections = {{
				type = "output",
				position = {-1,-5.5}
			}},
			pipe_covers = pipe_covers
		}
	},
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['assembling-machine']['chemical-plant'].working_sound,
	flags = {
		"placeable-neutral",
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
	selection_box = {{-2.5,-5},{2.5,5}},
	type = "assembling-machine"
}

local refineryitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-manufacturer",
	type = "item"
}

local ingredients = {
	{"motor",10},
	{"encased-industrial-beam",10},
	{"steel-pipe",30},
	{"copper-plate",20}
}
local refineryrecipe = {
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
local _group = data.raw['item-subgroup'][refineryitem.subgroup]
local refineryrecipe_undo = {
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
	order = _group.order .. "-" .. refineryitem.order,
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

data:extend({refinery,refineryitem,refineryrecipe,refineryrecipe_undo})
