local name = "biomass-burner"
local burner = {
	animation = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {128,128},
	},
	collision_box = {{-1.8,-1.8},{1.8,1.8}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	burner = {
		type = "burner",
		fuel_category = "chemical",
		fuel_inventory_size = 1
	},
	max_power_output = "30MW",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['furnace']['stone-furnace'].working_sound,
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"no-automated-item-removal",
		"no-automated-item-insertion"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name,
	selection_box = {{-2,-2},{2,2}},
	type = "burner-generator"
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
	collision_box = burner.collision_box,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name.."-accumulator",
	selection_box = burner.selection_box,
	selection_priority = 30,
	type = "accumulator"
}

local burneritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-power",
	type = "item"
}

local ingredients = {
	{"iron-plate",15},
	{"iron-stick",15},
	{"wire",25}
}
local burnerrecipe = {
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
local _group = data.raw['item-subgroup'][burneritem.subgroup]
local burnerrecipe_undo = {
	name = name.."-undo",
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. burneritem.order,
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

data:extend({burner,accumulator,burneritem,burnerrecipe,burnerrecipe_undo})
