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

local item = data.raw.item[name]
item.icon = ore.icon
item.icon_mipmaps = 0
item.stack_size = 100
item.fuel_category = "carbon"
item.fuel_value = "300MJ"
item.pictures = nil