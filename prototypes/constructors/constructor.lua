local name = "constructor"
local constructor = {
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,160}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {160,96}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,160}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {160,96}
		}
	},
	collision_box = {{-1.3,-2.3},{1.3,2.3}},
	corpse = "big-remnants",
	crafting_categories = {"constructing"},
	crafting_speed = 1,
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "4MW",
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
	selection_box = {{-1.5,-2.5},{1.5,2.5}},
	type = "assembling-machine"
}

local constructoritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-manufacturer",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",2},
	{"copper-cable",8}
}
local constructorrecipe = {
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
local constructorrecipe_undo = {
	name = name.."-undo",
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = constructoritem.subgroup .. "-undo",
	order = constructoritem.order,
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

data:extend({constructor,constructoritem,constructorrecipe,constructorrecipe_undo})