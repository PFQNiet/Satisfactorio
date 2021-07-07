require("prototypes.power.biomass-burner-hub")
require("prototypes.power.biomass-burner")
require("prototypes.power.coal-generator")
require("prototypes.power.fuel-generator")
require("prototypes.power.nuclear-power-plant")
require("prototypes.power.geothermal-generator")
require("prototypes.power.power-poles")
require("prototypes.power.power-storage")
require("prototypes.power.power-switch")

data:extend{
	{type="recipe-category",name="coal-generator"},
	{type="recipe-category",name="fuel-generator"},
	{type="recipe-category",name="nuclear-power"},
	{
		type = "sound",
		name = "power-startup",
		filename = "__base__/sound/nightvision-on.ogg"
	},
	{
		type = "sound",
		name = "power-failure",
		filename = "__base__/sound/nightvision-off.ogg"
	}
}
