-- Generator consists of a "fuel tank" and an electric interface

local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}

local name = "fuel-generator"
local storage = {
	type = "storage-tank",
	name = name,
	flow_length_in_ticks = 360,
	window_bounding_box = {{-0.125,0.6875},{0.1875,1.1875}},
	pictures = {
		window_background = data.raw['storage-tank']['storage-tank'].pictures.window_background,
		fluid_background = data.raw['storage-tank']['storage-tank'].pictures.fluid_background,
		flow_sprite = data.raw['storage-tank']['storage-tank'].pictures.flow_sprite,
		gas_flow = data.raw['storage-tank']['storage-tank'].pictures.gas_flow,
		picture = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
			size = {320,320}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_box = {
		base_area = 0.1,
		base_level = -1,
		pipe_connections = {
			{
				type = "input",
				position = {0.5,-5.5}
			}
		},
		pipe_covers = table.deepcopy(data.raw['storage-tank']['storage-tank'].fluid_box.pipe_covers)
	},
	minable = {
		mining_time = 1,
		result = name
	},
	selection_box = {{-5,-5},{5,5}},
	selection_priority = 40,
	working_sound = data.raw['assembling-machine']['oil-refinery'].working_sound
}
local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	energy_source = {
		type = "electric",
		buffer_capacity = "150MW",
		usage_priority = "secondary-output",
		drain = "0W"
	},
	energy_production = "150MW", -- may be adjusted in case of low fuel
	pictures = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-blueprintable",
		"no-copy-paste"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	placeable_by = {item=name,count=1},
	selection_box = {{-5,-5},{5,5}}
}
local accumulator = {
	picture = empty_sprite,
	energy_source = {
		type = "electric",
		buffer_capacity = "1J",
		usage_priority = "tertiary"
	},
	charge_cooldown = 0,
	discharge_cooldown = 0,
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name.."-accumulator",
	selection_box = {{-5,-5},{5,5}},
	selection_priority = 30,
	type = "accumulator"
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

data:extend({storage, interface, accumulator, generatoritem, generatorrecipe, generatorrecipe_undo})
