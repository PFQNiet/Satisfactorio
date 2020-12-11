local name = "space-elevator"
local elevator = {
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {864,864}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {864,864}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {864,864}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {864,864}
		}
	},
	collision_box = {{-13.21,-13.2},{13.21,13.2}},
	corpse = "big-remnants",
	crafting_categories = {"space-elevator"},
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
		"player-creation"
	},
	draw_entity_info_icon_background = false,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 5,
		result = name
	},
	name = name,
	selection_box = {{-13.5,-13.5},{13.5,13.5}},
	type = "assembling-machine",
	return_ingredients_on_change = false
}

local elevatoritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "special",
	type = "item"
}

local ingredients = {
	{"concrete",500},
	{"iron-plate",250},
	{"iron-stick",400},
	{"wire",1500}
}
local elevatorrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 10,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][elevatoritem.subgroup]
local elevatorrecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 10,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. elevatoritem.order,
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

data:extend({elevator,elevatoritem,elevatorrecipe,elevatorrecipe_undo})

local silo = table.deepcopy(data.raw['rocket-silo']['rocket-silo'])
silo.name = "space-elevator-silo"
silo.energy_source = {type="void"}
silo.rocket_parts_required = 1
silo.max_health = 1
silo.fixed_recipe = nil
silo.selection_priority = 49

local siloitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = silo.name,
	flags = {"hidden"},
	order = "c["..silo.name.."]",
	subgroup = "special",
	stack_size = 1,
	type = "item"
}

data:extend({silo,siloitem})
