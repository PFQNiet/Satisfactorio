-- resource wells consist of a "well" node surrounded by a number of satellite nodes
-- the "well" node is just a placeholder and produces nothing, but its miner accepts modules to affect the satellites
local template = {
	type = "resource",
	-- name = "resource-well", -- to be populated in clones
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/resource-well-pressuriser.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	flags = {"placeable-neutral"},
	order = "x",
	category = "resource-well",
	minable = {
		mining_time = 2,
		results = {{
			type = "fluid",
			-- name = "water", -- to be populated in clones
			amount_min = 0,
			amount_max = 0,
			probability = 1
		}}
	},
	collision_box = {{-4.9, -4.9}, {4.9, 4.9}},
	selection_box = {{-3, -3}, {3, 3}},
	selection_priority = 25,
	autoplace = nil,
	stage_counts = {0},
	stages = {
		sheet = {
			filename = "__Satisfactorio__/graphics/resources/resource-well.png",
			frame_count = 6,
			width = 1500 / 6,
			height = 250,
			variation_count = 1
		}
	},
	highlight = true,
	map_color = {r=0, g=0, b=0},
	infinite = true,
	infinite_depletion_amount = 0,
	minimum = 1,
	normal = 3000,
	map_grid = false,
	resource_patch_search_radius = 10
}

local water = table.deepcopy(template)
water.name = "water-well"
water.minable.results[1].name = "water"
water.map_color = data.raw.resource['water'].map_color
local oil = table.deepcopy(template)
oil.name = "crude-oil-well"
oil.icons[2].icon = "__Satisfactorio__/graphics/icons/crude-oil.png"
oil.minable.results[1].name = "crude-oil"
oil.map_color = data.raw.resource['crude-oil'].map_color
local nitro = table.deepcopy(template)
nitro.name = "nitrogen-gas-well"
nitro.icons[2].icon = "__Satisfactorio__/graphics/icons/nitrogen-gas.png"
nitro.minable.results[1].name = "nitrogen-gas"
nitro.map_color = {r=180,g=180,b=180}
data:extend({water,oil,nitro})

template = {
	type = "resource",
	-- name = "resource-node", -- to be populated in clones
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/resource-well-extractor.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	flags = {"placeable-neutral"},
	order = "y",
	category = "resource-node",
	minable = {
		mining_time = 1,
		results = {{
			type = "fluid",
			-- name = "water", -- to be populated in clones
			amount_min = 0.5,
			amount_max = 0.5,
			probability = 1
		}}
	},
	collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	autoplace = nil,
	stage_counts = {0},
	-- stages = {}, -- to be populated in clones
	highlight = true,
	map_color = {r=0, g=0, b=0},
	infinite = true,
	infinite_depletion_amount = 0,
	minimum = 1,
	normal = 3000,
	map_grid = false,
	resource_patch_search_radius = 10
}

water = table.deepcopy(template)
water.name = "water-node"
water.minable.results[1].name = "water"
water.map_color = data.raw.resource['water'].map_color
water.stages = table.deepcopy(data.raw.resource['water'].stages)
oil = table.deepcopy(template)
oil.name = "crude-oil-node"
oil.icons[2].icon = "__Satisfactorio__/graphics/icons/crude-oil.png"
oil.minable.results[1].name = "crude-oil"
oil.map_color = data.raw.resource['crude-oil'].map_color
oil.stages = table.deepcopy(data.raw.resource['crude-oil'].stages)
nitro = table.deepcopy(template)
nitro.name = "nitrogen-gas-node"
nitro.icons[2].icon = "__Satisfactorio__/graphics/icons/nitrogen-gas.png"
nitro.minable.results[1].name = "nitrogen-gas"
nitro.map_color = {r=180,g=180,b=180}
nitro.stages = {sheet = {
	filename = "__Satisfactorio__/graphics/resources/gas-vent.png",
	frame_count = 8,
	width = 1024/8,
	height = 128,
	variation_count = 1
}}
data:extend({water,oil,nitro})

data:extend({
	{
		type = "autoplace-control",
		name = "water-well",
		order = "l",
		richness = true,
		category = "resource"
	},
	{
		type = "autoplace-control",
		name = "crude-oil-well",
		order = "m",
		richness = true,
		category = "resource"
	},
	{
		type = "autoplace-control",
		name = "nitrogen-gas-well",
		order = "n",
		richness = true,
		category = "resource"
	},
	{
		type = "noise-layer",
		name = "water-well"
	},
	{
		type = "noise-layer",
		name = "crude-oil-well"
	},
	{
		type = "noise-layer",
		name = "nitrogen-gas-well"
	}
})
