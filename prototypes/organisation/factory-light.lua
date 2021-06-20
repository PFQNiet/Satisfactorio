-- tweak the Small Lamp
local name = "factory-light"
local basename = "small-lamp"
local lamp = data.raw.lamp[basename]
-- lamp.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
-- lamp.icon_mipmaps = 0
lamp.max_health = 1
lamp.energy_usage_per_tick = "1MW"

local lampitem = data.raw.item[basename]
lampitem.stack_size = 50
lampitem.subgroup = "logistics-observation"

local ingredients = {
	{"quartz-crystal",20},
	{"wire",16},
	{"steel-plate",6}
}
local lamprecipe = {
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
local _group = data.raw['item-subgroup'][lampitem.subgroup]
local lamprecipe_undo = {
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
	order = _group.order .. "-" .. lampitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__base__/graphics/icons/"..basename..".png", icon_size = 64, icon_mipmaps = 3}
	},
	enabled = false
}

data.raw.recipe[basename] = lamprecipe
data:extend({lamprecipe_undo})
