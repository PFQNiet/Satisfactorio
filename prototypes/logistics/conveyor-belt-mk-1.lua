-- it's just a standard transport belt :D
local name = "conveyor-belt-mk-1"
local basename = "transport-belt"
local belt = data.raw['transport-belt']['transport-belt']
belt.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
belt.icon_mipmaps = 0
belt.max_health = 1
belt.speed = 1/256

local beltitem = data.raw.item['transport-belt']
beltitem.icon = belt.icon
beltitem.icon_mipmaps = 0
beltitem.stack_size = 50

local ingredients = {{"iron-plate",1}}
local beltrecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 0.1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true
}
local beltrecipe_undo = {
	name = basename.."-undo",
	type = "recipe",
	ingredients = {
		{basename,1}
	},
	results = ingredients,
	energy_required = 0.1,
	category = "unbuilding",
	subgroup = beltitem.subgroup .. "-undo",
	order = beltitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	}
}

data.raw.recipe[basename] = beltrecipe
data:extend({beltrecipe_undo})