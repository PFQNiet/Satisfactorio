-- tweak the Small Electric Pole
local name = "power-pole-mk-1"
local basename = "small-electric-pole"
local pole = data.raw['electric-pole'][basename]
pole.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pole.icon_mipmaps = 0
pole.max_health = 1

local poleitem = data.raw.item[basename]
poleitem.icon = pole.icon
poleitem.icon_mipmaps = 0
poleitem.stack_size = 50

local ingredients = {
	{"wire",3},
	{"iron-stick",1},
	{"concrete",1}
}
local polerecipe = {
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
local polerecipe_undo = {
	name = basename.."-undo",
	type = "recipe",
	ingredients = {
		{basename,1}
	},
	results = ingredients,
	energy_required = 0.1,
	category = "unbuilding",
	subgroup = poleitem.subgroup .. "-undo",
	order = poleitem.order,
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