-- tweak vanilla train!
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
train.icon = graphics.."icons/electric-locomotive.png"
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
	icon = graphics.."icons/power.png",
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
data:extend{fuel, fuelcat, fuelcaticon}

local recipe = makeBuildingRecipe{
	name = "locomotive",
	ingredients = {
		{"heavy-modular-frame",5},
		{"motor",10},
		{"steel-pipe",15},
		{"computer",5}
	},
	result = "locomotive"
}
data.raw.recipe.locomotive = recipe
