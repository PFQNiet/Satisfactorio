local placeholder = require("graphics.placeholders.builder")

local name = "lookout-tower"
local animation = placeholder().addBox(-1.5,-1.5,4,4,{},{}).addIcon(graphics.."icons/"..name..".png",64).result()
for _,layer in pairs(animation.layers) do layer.direction_count = 1 end
local tower = {
	-- the "tower" is actually a car; entering the car sets the zoom level really far out
	type = "car",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-1.7,-1.7},{1.7,1.7}},
	collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"},
	selection_box = {{-2,-2},{2,2}},
	animation = animation,
	braking_power = "200kW",
	burner = {
		effectivity = 1,
		fuel_category = "chemical",
		fuel_inventory_size = 0,
		render_no_power_icon = false
	},
	consumption = "1W",
	effectivity = 0.5,
	weight = 1,
	braking_force = 1,
	friction_force = 1,
	energy_per_hit_point = 1,
	inventory_size = 0,
	rotation_speed = 0,
	max_health = 100, -- entity itself is not invincible, but this will be detected to pass-thru damage from attacks, gas, radiation etc.
	minable = {
		mining_time = 0.5,
		result = name
	},
	mined_sound = data.raw["utility-sounds"].default.deconstruct_big,
	flags = {
		"not-on-map",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"not-rotatable"
	}
}

local toweritem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "logistics-observation",
	order = "a["..name.."]"
}

local towerrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"iron-plate",5},
		{"iron-rod",5}
	},
	result = name
}

data:extend{tower,toweritem,towerrecipe}
