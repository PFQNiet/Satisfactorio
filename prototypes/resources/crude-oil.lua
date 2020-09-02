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
ore.collision_box = {{-0.1,-0.1},{0.1,0.1}}
ore.highlight = false
ore.minable.results = {{
	type = "fluid",
	name = name,
	amount_min = 0.5, -- originally 10
	amount_max = 0.5, -- originally 10
	probability = 1
}}

local fluid = data.raw.fluid[name]
fluid.icon = ore.icon
fluid.icon_mipmaps = 0