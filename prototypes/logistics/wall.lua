-- adjust vanilla Walls
local name = "wall"
local basename = "stone-wall"

local wall = data.raw.wall[basename]
wall.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
wall.icon_mipmaps = 0
wall.max_health = 1

local wallitem = data.raw.item[basename]
wallitem.icon = wall.icon
wallitem.icon_mipmaps = 0
wallitem.stack_size = 50
wallitem.order = "b["..basename.."]"
wallitem.subgroup = "logistics-wall"

local ingredients = {
	{"iron-plate",4},
	{"concrete",3}
}
local wallrecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][wallitem.subgroup]
local wallrecipe_undo = {
	name = basename.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..basename}},
	type = "recipe",
	ingredients = {
		{basename,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. wallitem.order,
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

data.raw.recipe[basename] = wallrecipe
data:extend({wallrecipe_undo})
