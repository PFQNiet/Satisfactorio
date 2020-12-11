-- clone express belt and up the speed!
local name = "conveyor-belt-mk-4"
local sourcename = "express-transport-belt"
local basename = "turbo-transport-belt"
local belt = table.deepcopy(data.raw['transport-belt'][sourcename])
belt.name = basename
belt.order = "a[transport-belt]-d["..basename.."]"
belt.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
belt.icon_mipmaps = 0
belt.max_health = 1
belt.speed = 4/256
belt.belt_animation_set.animation_set.filename = "__Satisfactorio__/graphics/entities/"..basename.."/"..basename..".png"
belt.belt_animation_set.animation_set.hr_version.filename = "__Satisfactorio__/graphics/entities/"..basename.."/hr-"..basename..".png"
belt.minable.result = basename
belt.next_upgrade = "ultimate-transport-belt"

local beltitem = table.deepcopy(data.raw.item[sourcename])
beltitem.name = basename
beltitem.icon = belt.icon
beltitem.icon_mipmaps = 0
beltitem.stack_size = 50
beltitem.place_result = basename
beltitem.order = belt.order

local ingredients = {{"encased-industrial-beam",1}}
local beltrecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 0.1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][beltitem.subgroup]
local beltrecipe_undo = {
	name = basename.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..basename}},
	show_amount_in_title = false,
	type = "recipe",
	ingredients = {
		{basename,1}
	},
	results = ingredients,
	energy_required = 0.1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. beltitem.order,
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

data:extend({belt, beltitem, beltrecipe, beltrecipe_undo})
