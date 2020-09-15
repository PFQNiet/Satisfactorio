-- it's just a standard underground belt :D
local name = "conveyor-lift-mk-1"
local basename = "underground-belt"
local belt = data.raw['underground-belt'][basename]
belt.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
belt.icon_mipmaps = 0
belt.max_health = 1
belt.speed = 1/256

local beltitem = data.raw.item[basename]
beltitem.icon = belt.icon
beltitem.icon_mipmaps = 0
beltitem.stack_size = 20

local ingredients = {{"iron-plate",8}}
local beltrecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	result_count = 2,
	energy_required = 0.5,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][beltitem.subgroup]
local beltrecipe_undo = {
	name = basename.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..basename}},
	show_amount_in_title = false,
	type = "recipe",
	ingredients = {
		{basename,2}
	},
	results = ingredients,
	energy_required = 0.5,
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

data.raw.recipe[basename] = beltrecipe
data:extend({beltrecipe_undo})
