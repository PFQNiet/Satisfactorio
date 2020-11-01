-- tweak vanilla Coal
local name = "coal"
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
ore.category = "solid"
ore.resource_patch_search_radius = 0
ore.order = "e"
if not ore.flags then ore.flags = {} end
table.insert(ore.flags,"not-on-map")
ore.collision_box = {{-2.1, -2.1}, {2.1, 2.1}}
ore.selection_box = {{-1.5,-1.5},{1.5,1.5}}
ore.stages.sheet.scale = 3
ore.stages.sheet.hr_version.scale = 1.5

local item = data.raw.item[name]
item.icon = ore.icon
item.icon_mipmaps = 0
item.stack_size = 100
item.fuel_category = "carbon"
item.fuel_value = "300MJ"
item.pictures = nil
item.subgroup = "mineral-resource"
item.order = "e"

local autoplace = data.raw['autoplace-control'][name]
autoplace.order = "e"
