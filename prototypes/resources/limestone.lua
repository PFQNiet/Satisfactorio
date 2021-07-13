-- tweak vanilla Stone (and rename)
local name = "stone"
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
ore.category = "solid"
ore.resource_patch_search_radius = 10
ore.order = "c"
ore.highlight = true
ore.collision_box = {{-1.6, -1.6}, {1.6, 1.6}}
ore.selection_box = {{-1.5,-1.5},{1.5,1.5}}
ore.stages.sheet.scale = 3
ore.stages.sheet.hr_version.scale = 1.5
ore.tile_width = 3
ore.tile_height = 3

local item = data.raw.item[name]
item.icon = ore.icon
item.icon_mipmaps = 0
item.stack_size = 100
item.pictures = nil
item.subgroup = "mineral-resource"
item.order = "c"

local autoplace = data.raw['autoplace-control'][name]
autoplace.order = "c"
