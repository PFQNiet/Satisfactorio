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
ore.resource_patch_search_radius = 1
ore.highlight = false
ore.minable.results = {{
	type = "fluid",
	name = name,
	amount_min = 1, -- originally 10
	amount_max = 1, -- originally 10
	probability = 1
}}
ore.category = "crude-oil"
ore.resource_patch_search_radius = 0
ore.order = "f"
if not ore.flags then ore.flags = {} end
table.insert(ore.flags,"not-on-map")
ore.collision_box = {{-2.1, -2.1}, {2.1, 2.1}}
ore.selection_box = {{-1.5,-1.5},{1.5,1.5}}
-- ore.stages.sheet.scale = 3 -- crude oil was already meant to be 3x3
-- ore.stages.sheet.hr_version.scale = 1.5

local fluid = data.raw.fluid[name]
fluid.icon = ore.icon
fluid.icon_mipmaps = 0
fluid.subgroup = "fluid-resource"
fluid.order = "b["..name.."]"

local autoplace = data.raw['autoplace-control'][name]
autoplace.order = "f"
