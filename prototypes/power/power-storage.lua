-- tweak the Accumulator
local name = "power-storage"
local basename = "accumulator"
local accumulator = data.raw.accumulator[basename]
accumulator.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
accumulator.icon_mipmaps = 0
accumulator.max_health = 1
accumulator.charge_animation = nil
accumulator.discharge_animation = nil
accumulator.energy_source = {
	type = "electric",
	buffer_capacity = "360GJ",
	usage_priority = "tertiary",
	input_flow_limit = "100MW"
}
accumulator.energy_usage = "30MW"
accumulator.selection_box = {{-1.5,-1.5},{1.5,1.5}}
accumulator.collision_box = {{-1.2,-1.2},{1.2,1.2}}
accumulator.picture = {
	filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
	direction_count = 1,
	size = {96,96}
}

local accumulatoritem = data.raw.item[basename]
accumulatoritem.icon = accumulator.icon
accumulatoritem.icon_mipmaps = 0
accumulatoritem.stack_size = 50
accumulatoritem.subgroup = "production-power"
accumulatoritem.order = "g[power-storage]"

local ingredients = {
	{"wire",100},
	{"modular-frame",10},
	{"stator",5}
}
local accumulatorrecipe = {
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
local _group = data.raw['item-subgroup'][accumulatoritem.subgroup]
local accumulatorrecipe_undo = {
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
	order = _group.order .. "-" .. accumulatoritem.order,
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

data.raw.recipe[basename] = accumulatorrecipe
data:extend({accumulatorrecipe_undo})
