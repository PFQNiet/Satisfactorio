local name = "equipment-workshop"
local workshop = {
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {160,96}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {96,160}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {160,96}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {96,160}
		}
	},
	collision_box = {{-2.2,-1.2},{2.2,1.2}},
	crafting_categories = {"equipment"},
	crafting_speed = 1,
	energy_source = {type="void"},
	energy_usage = "1W",
	open_sound = data.raw['assembling-machine']['assembling-machine-1'].open_sound,
	close_sound = data.raw['assembling-machine']['assembling-machine-1'].close_sound,
	working_sound = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'].working_sound),
	flags = {
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
	selection_box = {{-2.5,-1.5},{2.5,1.5}},
	type = "assembling-machine"
}
workshop.working_sound.sound[1].filename = "__base__/sound/manual-repair-simple.ogg"

local workshopitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-workstation",
	type = "item"
}

local ingredients = {
	{"iron-plate",6},
	{"iron-stick",4}
}
local workshoprecipe = {
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
local _group = data.raw['item-subgroup'][workshopitem.subgroup]
local workshoprecipe_undo = {
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
	order = _group.order .. "-" .. workshopitem.order,
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

data:extend({workshop,workshopitem,workshoprecipe,workshoprecipe_undo})