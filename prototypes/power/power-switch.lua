-- tweak the Power Switch
local name = "power-switch"
local pole = data.raw['power-switch'][name]
pole.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pole.icon_mipmaps = 0
pole.max_health = 1

local poleitem = data.raw.item[name]
poleitem.icon = pole.icon
poleitem.icon_mipmaps = 0
poleitem.stack_size = 50
poleitem.subgroup = "energy-pipe-distribution"

local ingredients = {
	{"quickwire",20},
	{"steel-plate",4},
	{"processing-unit",1}
}
local polerecipe = {
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
local _group = data.raw['item-subgroup'][poleitem.subgroup]
local polerecipe_undo = {
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

data.raw.recipe[name] = polerecipe
data:extend({polerecipe_undo})
