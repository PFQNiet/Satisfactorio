local name = "assembler"
local assembler = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {160,224}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {224,160}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {160,224}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {224,160}
		}
	},
	collision_box = {{-2.2,-3.2},{2.2,3.2}},
	corpse = "big-remnants",
	crafting_categories = {"assembling"},
	crafting_speed = 1,
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "15MW",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['assembling-machine']['assembling-machine-2'].working_sound,
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
	selection_box = {{-2.5,-3.5},{2.5,3.5}},
	type = "assembling-machine"
}

local assembleritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-manufacturer",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",8},
	{"rotor",4},
	{"copper-cable",10}
}
local assemblerrecipe = {
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
local _group = data.raw['item-subgroup'][assembleritem.subgroup]
local assemblerrecipe_undo = {
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
	order = _group.order .. "-" .. assembleritem.order,
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

data:extend({assembler,assembleritem,assemblerrecipe,assemblerrecipe_undo})