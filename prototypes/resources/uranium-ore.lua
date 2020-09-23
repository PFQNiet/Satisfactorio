-- tweak vanilla Uranium Ore
local name = "uranium-ore"
local ore = data.raw.resource[name]
ore.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
ore.icon_mipmaps = 0
ore.autoplace = nil
ore.stage_counts = {240,200,120,80,60,0,0,0}
ore.infinite = true
ore.infinite_depletion_amount = 0
ore.minimum = 1
ore.normal = 60
ore.map_grid = false
ore.resource_patch_search_radius = 1
local mining = ore.minable
mining.required_fluid = nil
mining.fluid_amount = 0
mining.mining_time = 1
ore.category = "solid"
ore.resource_patch_search_radius = 0
ore.order = "k"
if not ore.flags then ore.flags = {} end
table.insert(ore.flags,"not-on-map")

local item = data.raw.item[name]
item.icon = ore.icon
item.icon_mipmaps = 0
item.stack_size = 100
item.pictures = nil
item.subgroup = "mineral-resource"
item.order = "k"

local autoplace = data.raw['autoplace-control'][name]
autoplace.order = "k"
