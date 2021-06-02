local name = "pipeline"
local basename = "pipe"

-- flow rate calculated as 300/min over 20 pipes
local pipe = data.raw.pipe[basename]
local box = pipe.fluid_box
pipe.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pipe.icon_size = 64
pipe.icon_mipmaps = 0
pipe.max_health = 1
pipe.collision_mask = {"object-layer","train-layer"}
box.height = 0.0065
box.base_area = 0.01/box.height

local pipeitem = data.raw.item[basename]
pipeitem.icon = pipe.icon
pipeitem.icon_mipmaps = 0
pipeitem.stack_size = 50
pipeitem.subgroup = "pipe-distribution"

local ingredients = {{"copper-plate",1}}
local piperecipe = {
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
local _group = data.raw['item-subgroup'][pipeitem.subgroup]
local piperecipe_undo = {
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
	order = _group.order .. "-" .. pipeitem.order,
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

data.raw.recipe[basename] = piperecipe
data:extend({piperecipe_undo})
