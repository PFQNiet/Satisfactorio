-- tweak the Radar
local name = "radar-tower"
local radar = table.deepcopy(data.raw.radar.radar)
radar.name = name
radar.minable = {mining_time = 0.5, result = name}
radar.icon = graphics.."icons/"..name..".png"
radar.icon_mipmaps = 0
radar.max_health = 1
radar.energy_per_nearby_scan = "30MJ"
radar.max_distance_of_nearby_sector_revealed = 4
radar.energy_per_sector = "100MJ"
radar.max_distance_of_sector_revealed = 14
radar.energy_source.buffer_capacity = "30MW"
radar.energy_usage = "30MW"
radar.selection_box = {{-2.5,-2.5},{2.5,2.5}}
radar.collision_box = {{-2.2,-2.2},{2.2,2.2}}
-- radar.pictures = placeholder().addBox(-2,-2,5,5,{},{}).addIcon(graphics.."icons/"..name..".png",64).result()
-- for _,layer in pairs(radar.pictures.layers) do layer.direction_count = 1 end

local radaritem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "logistics-observation",
	order = "b["..name.."]"
}

local radarrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"heavy-modular-frame",30},
		{"crystal-oscillator",30},
		{"map-marker",20},
		{"copper-cable",100}
	},
	result = name
}

data:extend{radar, radaritem, radarrecipe}
