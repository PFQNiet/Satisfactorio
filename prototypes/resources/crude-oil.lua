-- tweak vanilla Crude Oil
local name = "crude-oil"
local ore = data.raw.resource[name]
ore.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
ore.icon_mipmaps = 0
ore.autoplace = nil
ore.infinite = true
ore.infinite_depletion_amount = 0
ore.minimum = 1
ore.normal = 60
ore.map_grid = false
ore.minable.results = {{
	type = "fluid",
	name = name,
	amount_min = 1, -- originally 10
	amount_max = 1, -- originally 10
	probability = 1
}}
ore.category = "crude-oil"
ore.map_color = {0.3,0,0.3}
ore.resource_patch_search_radius = 10
ore.order = "f"
ore.highlight = true
ore.collision_box = {{-1.6, -1.6}, {1.6, 1.6}}
ore.selection_box = {{-1.5,-1.5},{1.5,1.5}}
ore.stages.sheet.scale = 1.5 -- crude oil was already meant to be 3x3
ore.stages.sheet.hr_version.scale = 0.75
ore.tile_width = 3
ore.tile_height = 3

local fluid = data.raw.fluid[name]
fluid.icon = ore.icon
fluid.icon_mipmaps = 0
fluid.subgroup = "fluid-resource"
fluid.order = "a[fluid-resource]-f["..name.."]"

local autoplace = data.raw['autoplace-control'][name]
autoplace.order = "f"
