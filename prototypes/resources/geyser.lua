local name = "geyser"
-- "collides" with water-tile so that buildings and such can't be placed on it - except for the Geothermal Generator which has no collision.
data:extend(
{
	{
		type = "resource",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		flags = {"placeable-neutral"},
		order = "r",
		category = "geothermal",
		tree_removal_probability = 0,
		tree_removal_max_distance = 0,
		randomize_visual_position = false,
		minable = {
			result = name,
			mining_time = 1
		},
		collision_box = {{ -2.1, -2.1}, {2.1, 2.1}},
		collision_mask = {"resource-layer", "water-tile"},
		selection_box = {{ -2.5, -2.5}, {2.5, 2.5}},
		selection_priority = 25, -- below most entities, but not Foundation
		autoplace = nil,
		stage_counts = {0},
		stages = {
			sheet = {
				filename = graphics.."placeholders/"..name..".png",
				priority = "extra-high",
				width = 160,
				height = 160,
				frame_count = 1,
				variation_count = 1
			}
		},
		map_color = {r=0.8, g=0.8, b=0.8},
		infinite = true,
		infinite_depletion_amount = 0,
		minimum = 1,
		normal = 60,
		map_grid = false,
		tile_width = 5,
		tile_height = 5,
		highlight = true,
		resource_patch_search_radius = 10
	},
	{
		type = "autoplace-control",
		name = name,
		order = "v",
		richness = false,
		category = "terrain"
	},
	{
		type = "noise-layer",
		name = name
	},
	{
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		flags = {"hidden"}, -- exists only for locale texts and Resource Scanner "recipe"
		subgroup = "mineral-resource",
		order = "r["..name.."]",
		stack_size = 1
	}
})
