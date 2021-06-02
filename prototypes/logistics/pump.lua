local name = "pipeline-pump"
local basename = "pump"

local pump = data.raw.pump[basename]
local box = pump.fluid_box
pump.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pump.icon_size = 64
pump.icon_mipmaps = 0
pump.pumping_speed = 300/60/60 -- 300/minute
pump.max_health = 1
box.base_area = 0.02/box.height -- capacity = 2m^3
pump.energy_source.drain = "0W"
pump.energy_source.buffer_capacity = "4MW"
pump.energy_source.input_flow_limit = "4MW"
pump.energy_usage = "4MW"

local pumpitem = data.raw.item[basename]
pumpitem.icon = pump.icon
pumpitem.icon_mipmaps = 0
pumpitem.stack_size = 5
pumpitem.subgroup = "pipe-distribution"

local ingredients = {{"copper-plate",2},{"rotor",2}}
local pumprecipe = {
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
local _group = data.raw['item-subgroup'][pumpitem.subgroup]
local pumprecipe_undo = {
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
	order = _group.order .. "-" .. pumpitem.order,
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

data.raw.recipe[basename] = pumprecipe
data:extend({pumprecipe_undo})
