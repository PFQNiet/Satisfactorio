local name = "biomass-burner-hub"
local burner = {
	animation = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {96,96},
	},
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	burner = {
		type = "burner",
		fuel_category = "chemical",
		fuel_inventory_size = 1
	},
	max_power_output = "20MW",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"not-deconstructable"
	},
	icon = "__Satisfactorio__/graphics/icons/biomass-burner.png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	type = "burner-generator"
}
local accumulator = {
	picture = {
		filename = "__core__/graphics/empty.png",
		size = {1,1}
	},
	energy_source = {
		type = "electric",
		buffer_capacity = "1J",
		usage_priority = "tertiary"
	},
	charge_cooldown = 0,
	discharge_cooldown = 0,
	collision_box = burner.collision_box,
	icon = "__Satisfactorio__/graphics/icons/biomass-burner.png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name.."-accumulator",
	selection_box = burner.selection_box,
	selection_priority = 30,
	type = "accumulator"
}

data:extend({burner,accumulator})
