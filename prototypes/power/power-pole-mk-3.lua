-- tweak the Big Electric Pole
local name = "power-pole-mk-3"
local basename = "big-electric-pole"
local pole = data.raw['electric-pole'][basename]
pole.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pole.icon_mipmaps = 0
pole.max_health = 1
pole.selection_box = data.raw['electric-pole']['medium-electric-pole'].selection_box
pole.collision_box = data.raw['electric-pole']['medium-electric-pole'].collision_box
pole.supply_area_distance = 1.5
pole.fast_replaceable_group = data.raw['electric-pole']['medium-electric-pole'].fast_replaceable_group

local poleitem = data.raw.item[basename]
poleitem.icon = pole.icon
poleitem.icon_mipmaps = 0
poleitem.stack_size = 50

local ingredients = {
	{"advanced-circuit",2},
	{"steel-pipe",2},
	{"concrete",3}
}
local polerecipe = {
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
local _group = data.raw['item-subgroup'][poleitem.subgroup]
local polerecipe_undo = {
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
	order = _group.order .. "-" .. poleitem.order,
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

data.raw.recipe[basename] = polerecipe
data:extend({polerecipe_undo})
