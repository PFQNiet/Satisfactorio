-- tweak vanilla Sulfuric Acid
local name = "sulfuric-acid"

local fluid = data.raw.fluid[name]
fluid.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
fluid.icon_mipmaps = 0
fluid.subgroup = "fluid-product"
fluid.order = "b[fluid-products]-c["..name.."]"

data.raw.recipe[name] = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = {
		{"sulfur",5},
		{type="fluid",name="water",amount=5}
	},
	results = {{type="fluid",name=name,amount=5}},
	subgroup = "fluid-recipe",
	energy_required = 6,
	category = "refining",
	enabled = false
}
