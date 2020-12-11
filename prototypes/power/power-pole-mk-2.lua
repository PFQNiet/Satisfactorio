-- tweak the Medium Electric Pole
local name = "power-pole-mk-2"
local basename = "medium-electric-pole"
local pole = data.raw['electric-pole'][basename]
pole.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pole.icon_mipmaps = 0
pole.max_health = 1
pole.next_upgrade = "big-electric-pole"

local poleitem = data.raw.item[basename]
poleitem.icon = pole.icon
poleitem.icon_mipmaps = 0
poleitem.stack_size = 50

local ingredients = {
	{"quickwire",6},
	{"iron-stick",2},
	{"concrete",2}
}
local polerecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 0.5,
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
	energy_required = 0.5,
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
