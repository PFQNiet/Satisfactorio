-- tweak vanilla Heavy Oil
local name = "heavy-oil-residue"
local basename = "heavy-oil"

local fluid = data.raw.fluid[basename]
fluid.icon = graphics.."icons/"..name..".png"
fluid.icon_mipmaps = 0
fluid.subgroup = "fluid-product"
fluid.order = "b[fluid-products]-a["..name.."]"
