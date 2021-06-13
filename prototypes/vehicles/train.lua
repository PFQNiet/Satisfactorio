-- tweak vanilla train! Extend the joints by one tile so the train is in units of 8 tiles
local train = data.raw.locomotive.locomotive
train.max_health = 1
train.max_power = "85MW"
train.max_speed = 120*1000/3600/60 -- 120KMH
train.burner = {
	fuel_inventory_size = 0,
	fuel_category = "train-power"
}
train.weight = 850000/2
train.braking_force = train.weight/400
train.friction_force = train.braking_force/40

train = data.raw['item-with-entity-data']['locomotive']
train.icon = "__Satisfactorio__/graphics/icons/electric-locomotive.png"
train.icon_size = 64
train.icon_mipmaps = 1
train.stack_size = 50
local fuelcat = {
	type = "fuel-category",
	name = "train-power"
}
local fuel = {
	type = "item",
	name = "train-power",
	flags = {"hidden"},
	fuel_category = "train-power",
	fuel_value = "85MJ", -- 1 second of max power
	icon = "__Satisfactorio__/graphics/icons/battery.png",
	icon_size = 64,
	stack_size = 1
}
local fuelcaticon = {
	filename = "__core__/graphics/icons/tooltips/tooltip-category-electricity.png",
	flags = {"gui-icon"},
	height = 40,
	mipmap_count = 2,
	name = "tooltip-category-train-power",
	priority = "extra-high-no-scale",
	scale = 0.5,
	type = "sprite",
	width = 32
}

local ingredients = {
	{"heavy-modular-frame",5},
	{"motor",10},
	{"steel-pipe",15},
	{"computer",5},
	{"map-marker",5}
}
local recipe = {
	name = "locomotive",
	type = "recipe",
	ingredients = ingredients,
	result = "locomotive",
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
data.raw.recipe.locomotive = recipe
local _group = data.raw['item-subgroup'][train.subgroup]
local recipe_undo = {
	name = "locomotive-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name.locomotive"}},
	type = "recipe",
	ingredients = {
		{"locomotive",1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. train.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/electric-locomotive.png", icon_size = 64}
	},
	enabled = false
}
data:extend({fuel, fuelcat, fuelcaticon, recipe_undo})
