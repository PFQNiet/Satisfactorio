data.raw['straight-rail']['straight-rail'].max_health = 1
data.raw['curved-rail']['curved-rail'].max_health = 1

local rail = data.raw['rail-planner']['rail']
rail.icon = "__Satisfactorio__/graphics/icons/railway.png"
rail.icon_size = 64
rail.icon_mipmaps = 1
local ingredients = {
	{"steel-pipe",1},
	{"steel-plate",1}
}
local recipe = {
	name = "rail",
	type = "recipe",
	ingredients = ingredients,
	result = "rail",
	result_count = 6,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
data.raw.recipe.rail = recipe
local _group = data.raw['item-subgroup'][rail.subgroup]
local recipe_undo = {
	name = "rail-undo",
	localised_name = {"recipe-name.dismantle",{"item-name.rail"}},
	type = "recipe",
	ingredients = {
		{"rail",6}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. rail.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/railway.png", icon_size = 64}
	},
	enabled = false
}
data:extend({recipe_undo})

rail = data.raw.item['rail-signal']
local signal = data.raw.recipe['rail-signal']
signal.category = "building"
signal.allow_intermediates = false
signal.allow_as_intermediate = false
signal.hide_from_stats = true
signal.enabled = false
_group = data.raw['item-subgroup'][rail.subgroup]
recipe_undo = {
	name = "rail-signal-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name.rail-signal"}},
	type = "recipe",
	ingredients = {
		{"rail-signal",1}
	},
	results = signal.ingredients,
	energy_required = 0.5,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. rail.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__base__/graphics/icons/rail-signal.png", icon_size = 64, icon_mipmaps = 4}
	},
	enabled = false
}
data:extend({recipe_undo})

rail = data.raw.item['rail-chain-signal']
signal = data.raw.recipe['rail-chain-signal']
signal.category = "building"
signal.allow_intermediates = false
signal.allow_as_intermediate = false
signal.hide_from_stats = true
signal.enabled = false
_group = data.raw['item-subgroup'][rail.subgroup]
recipe_undo = {
	name = "rail-chain-signal-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name.rail-chain-signal"}},
	type = "recipe",
	ingredients = {
		{"rail-chain-signal",1}
	},
	results = signal.ingredients,
	energy_required = 0.5,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. rail.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__base__/graphics/icons/rail-chain-signal.png", icon_size = 64, icon_mipmaps = 4}
	},
	enabled = false
}
data:extend({recipe_undo})
