-- adjust vanilla Wood
local name = "wood"
local wood = data.raw.item[name]
wood.icon = graphics.."icons/"..name..".png"
wood.icon_mipmaps = 0
wood.stack_size = 100
wood.fuel_value = "100MJ"
wood.subgroup = "organic-resource"
wood.order = "b["..name.."]"
