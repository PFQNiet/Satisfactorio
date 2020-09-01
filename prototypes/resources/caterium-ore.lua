-- Caterium Ore
data:extend(
{
	{
		type = "resource",
		name = "caterium-ore",
		icon = "__base__/graphics/icons/stone.png",
		icon_size = 64,
		flags = {"placeable-neutral"},
		order="a-b-e",
		tree_removal_probability = 0,
		tree_removal_max_distance = 0,
		minable =
		{
			hardness = 1,
			mining_particle = "stone-particle",
			mining_time = 1,
			result = "caterium-ore"
		},
		collision_box = {{ -0.1, -0.1}, {0.1, 0.1}},
		selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
		autoplace = nil,
		stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
		stages =
		{
			sheet =
			{
				filename = "__base__/graphics/entity/stone/stone.png",
				priority = "extra-high",
				width = 64,
				height = 64,
				frame_count = 8,
				variation_count = 8,
				hr_version =
				{
					filename = "__base__/graphics/entity/stone/hr-stone.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					frame_count = 8,
					variation_count = 8,
					scale = 0.5
				}
			}
		},
		map_color = {r=0.8, g=0.8, b=0}
	},
	{
		type = "autoplace-control",
		name = "caterium-ore",
		order = "k-a",
		richness = true,
		category = "resource"
	},
	{
		type = "noise-layer",
		name = "caterium-ore"
	},
	{
		type = "item",
		name = "caterium-ore",
		icon = "__base__/graphics/icons/stone.png",
		icon_size = 64,
		icon_mipmaps = 4,
		pictures =
		{
			{ size = 64, filename = "__base__/graphics/icons/stone.png",   scale = 0.25, mipmap_count = 4 },
			{ size = 64, filename = "__base__/graphics/icons/stone-1.png", scale = 0.25, mipmap_count = 4 },
			{ size = 64, filename = "__base__/graphics/icons/stone-2.png", scale = 0.25, mipmap_count = 4 },
			{ size = 64, filename = "__base__/graphics/icons/stone-3.png", scale = 0.25, mipmap_count = 4 }
		},
		subgroup = "raw-material",
		order = "k[caterium-ore]",
		stack_size = 100
	}
})
