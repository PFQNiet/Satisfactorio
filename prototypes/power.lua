require("prototypes.power.biomass-burner-hub")
require("prototypes.power.biomass-burner")
-- generators produce "energy" fluid, which is then consumed by script
-- temperature is used to manipulate the tooltip, as it is an unused feature in Satisfactory and therefore locale tricks can be used instead to show MW
data:extend{
	{
		type = "fluid",
		name = "energy",
		order = "c[fuel]-x[energy]",
		subgroup = "fluid-fuel",
		icon = "__Satisfactorio__/graphics/icons/power.png",
		icon_size = 64,
		hidden = true,
		max_temperature = 25,
		default_temperature = 25,
		base_color = {51,204,255},
		flow_color = {51,204,255}
	}
}
require("prototypes.power.coal-generator")
require("prototypes.power.fuel-generator")
require("prototypes.power.nuclear-power-plant")
require("prototypes.power.geothermal-generator")
require("prototypes.power.power-storage")
require("prototypes.power.power-pole-mk-1")
require("prototypes.power.power-pole-mk-2")
require("prototypes.power.power-pole-mk-3")
require("prototypes.power.power-switch")
