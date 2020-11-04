-- tweak the Radar
local name = "radar-tower"
local basename = "radar"
local radar = data.raw.radar[basename]
radar.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
radar.icon_mipmaps = 0
radar.max_health = 1
radar.energy_per_nearby_scan = "30MJ"
radar.max_distance_of_nearby_sector_revealed = 4
radar.energy_per_sector = "100MJ"
radar.max_distance_of_sector_revealed = 14
radar.energy_usage = "30MW"
radar.selection_box = {{-2.5,-2.5},{2.5,2.5}}
radar.collision_box = {{-2.2,-2.2},{2.2,2.2}}
radar.pictures = {
	filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
	direction_count = 1,
	size = {160,160}
}

local radaritem = data.raw.item[basename]
radaritem.icon = radar.icon
radaritem.icon_mipmaps = 0
radaritem.stack_size = 1
radaritem.subgroup = "logistics-observation"

local ingredients = {
	{"heavy-modular-frame",30},
	{"crystal-oscillator",30},
	{"map-marker",20},
	{"copper-cable",100}
}
local radarrecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][radaritem.subgroup]
local radarrecipe_undo = {
	name = basename.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..basename}},
	type = "recipe",
	ingredients = {
		{basename,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. radaritem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data.raw.recipe[basename] = radarrecipe
data:extend({radarrecipe_undo})
