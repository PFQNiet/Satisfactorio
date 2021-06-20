local name = "craft-bench"
local bench = {
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,64}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {64,96}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,64}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {64,96}
		}
	},
	collision_box = {{-1.2,-0.7},{1.2,0.7}},
	crafting_categories = {"craft-bench"},
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
		mining_time = 0.5,
		result = name
	},
	name = name,
	selection_box = {{-1.5,-1.0},{1.5,1.0}},
	type = "assembling-machine"
}
bench.working_sound.sound[1].filename = "__base__/sound/manual-repair-simple.ogg"

local benchitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "production-workstation",
	type = "item"
}

local ingredients = {
	{"iron-plate",3},
	{"iron-stick",3}
}
local benchrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true
}
local _group = data.raw['item-subgroup'][benchitem.subgroup]
local benchrecipe_undo = {
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
	order = _group.order .. "-" .. benchitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	}
}

data:extend({bench,benchitem,benchrecipe,benchrecipe_undo})