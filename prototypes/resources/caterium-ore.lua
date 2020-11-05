local name = "caterium-ore"
data:extend(
{
	{
		type = "resource",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		flags = {"placeable-neutral"},
		order="g",
		category = "solid",
		tree_removal_probability = 0,
		tree_removal_max_distance = 0,
		minable =
		{
			hardness = 1,
			mining_particle = "stone-particle",
			mining_time = 1,
			result = name
		},
		collision_box = {{ -2.1, -2.1}, {2.1, 2.1}},
		selection_box = {{ -1.5, -1.5}, {1.5, 1.5}},
		autoplace = nil,
		stage_counts = {240,200,120,80,60,0,0,0},
		stages =
		{
			sheet =
			{
				filename = "__base__/graphics/entity/iron-ore/iron-ore.png",
				priority = "extra-high",
				width = 64,
				height = 64,
				frame_count = 8,
				variation_count = 8,
				tint = {0.8,0.8,0.2},
				scale = 3,
				hr_version =
				{
					filename = "__base__/graphics/entity/iron-ore/hr-iron-ore.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					frame_count = 8,
					variation_count = 8,
					tint = {0.8,0.8,0.2},
					scale = 1.5
				}
			}
		},
		map_color = {r=0.6, g=0.6, b=0},
		infinite = true,
		infinite_depletion_amount = 0,
		minimum = 1,
		normal = 60,
		map_grid = false,
		resource_patch_search_radius = 10
	},
	{
		type = "autoplace-control",
		name = name,
		order = "g",
		richness = true,
		category = "resource"
	},
	{
		type = "noise-layer",
		name = name
	},
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "mineral-resource",
		order = "g["..name.."]",
		stack_size = 100
	}
})
