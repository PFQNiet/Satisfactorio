local name = "mam"
local mam = {
	allowed_effects = {},
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {128,64}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {64,128}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {128,64}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {64,128}
		}
	},
	collision_box = {{-1.7,-0.7},{1.7,0.7}},
	corpse = "big-remnants",
	crafting_categories = {"mam"},
	crafting_speed = 1,
	dying_explosion = "big-explosion",
	energy_source = {type="void"},
	energy_usage = "1W",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"no-automated-item-removal",
		"no-automated-item-insertion"
	},
	draw_entity_info_icon_background = false,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name,
	selection_box = {{-2,-1},{2,1}},
	type = "assembling-machine"
}

local mamitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "special",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",5},
	{"copper-cable",15},
	{"wire",45}
}
local mamrecipe = {
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
local _group = data.raw['item-subgroup'][mamitem.subgroup]
local mamrecipe_undo = {
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
	order = _group.order .. "-" .. mamitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	always_show_products = true,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({mam,mamitem,mamrecipe,mamrecipe_undo})
