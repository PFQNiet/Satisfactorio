-- "fake" water node that is automatically spawned when you place a Water Extractor
local name = "water"
local node = {
	type = "resource",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	flags = {"placeable-neutral","not-on-map"},
	order = "w",
	category = "water",
	minable = {
		mining_time = 1,
		results = {{
			type = "fluid",
			name = name,
			amount_min = 1,
			amount_max = 1,
			probability = 1
		}}
	},
	collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
	selection_box = {{-1, -1}, {1, 1}},
	autoplace = nil,
	stage_counts = {0},
	stages = table.deepcopy(data.raw.resource['crude-oil'].stages),
	map_color = {r=0, g=0.8, b=0.8},
	infinite = true,
	infinite_depletion_amount = 0,
	minimum = 1,
	normal = 60,
	map_grid = false,
	resource_patch_search_radius = 0
}
data:extend({node})

local fluid = data.raw.fluid[name]
fluid.icon = node.icon
fluid.icon_mipmaps = 0
fluid.heat_capacity = "1MJ"
-- 100 degrees for the coal power, 500 degrees for nuclear power

data.raw.fluid['steam'].heat_capacity = fluid.heat_capacity
