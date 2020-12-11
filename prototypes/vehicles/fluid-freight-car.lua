local fluid = data.raw['fluid-wagon']['fluid-wagon']
fluid.capacity = 1600
fluid.max_health = 1
fluid.weight = 425000/2

fluid = data.raw['item-with-entity-data']['fluid-wagon']
fluid.icon = nil
fluid.icon_size = nil
fluid.icon_mipmaps = nil
fluid.icons = {
	{icon = "__Satisfactorio__/graphics/icons/freight-car.png", icon_size = 64},
	{icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
}

local ingredients = {
	{"heavy-modular-frame",4},
	{"steel-pipe",10}
}
local recipe = {
	name = "fluid-wagon",
	type = "recipe",
	ingredients = ingredients,
	result = "fluid-wagon",
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
data.raw.recipe['fluid-wagon'] = recipe
local _group = data.raw['item-subgroup'][fluid.subgroup]
local recipe_undo = {
	name = "fluid-wagon-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name.fluid-wagon"}},
	type = "recipe",
	ingredients = {
		{"fluid-wagon",1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. fluid.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/freight-car.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	enabled = false
}
data:extend({recipe_undo})
