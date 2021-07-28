local name = "power-storage"
local accumulator = table.deepcopy(data.raw.accumulator.accumulator)
accumulator.name = name
accumulator.minable = {mining_time = 0.5, result = name}
accumulator.icon = graphics.."icons/"..name..".png"
accumulator.icon_size = 64
accumulator.icon_mipmaps = 0
accumulator.max_health = 1
accumulator.charge_animation = nil
accumulator.discharge_animation = nil
accumulator.energy_source = {
	type = "electric",
	buffer_capacity = "360GJ", -- 100 MWh
	usage_priority = "tertiary",
	input_flow_limit = "100MW"
}
accumulator.selection_box = {{-1.5,-1.5},{1.5,1.5}}
accumulator.collision_box = {{-1.2,-1.2},{1.2,1.2}}
accumulator.picture = {
	filename = graphics.."placeholders/"..name..".png",
	direction_count = 1,
	size = {96,96}
}

local accumulatoritem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "production-power",
	order = "g["..name.."]"
}

local accumulatorrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"wire",100},
		{"modular-frame",10},
		{"stator",5}
	},
	result = name
}

data:extend{accumulator,accumulatoritem,accumulatorrecipe}
