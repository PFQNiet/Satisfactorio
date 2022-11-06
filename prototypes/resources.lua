-- modded vanilla resources
require("prototypes.resources.wood")
require("prototypes.resources.iron-ore")
require("prototypes.resources.copper-ore")
require("prototypes.resources.coal")
require("prototypes.resources.limestone")
require("prototypes.resources.uranium-ore")
require("prototypes.resources.crude-oil")

-- custom resources
require("prototypes.resources.water")
require("prototypes.resources.leaves")
require("prototypes.resources.flower-petals")
require("prototypes.resources.mycelia")
require("prototypes.resources.caterium-ore")
require("prototypes.resources.bauxite")
require("prototypes.resources.raw-quartz")
require("prototypes.resources.sulfur")
require("prototypes.resources.nitrogen-gas")
require("prototypes.resources.wells")
require("prototypes.resources.geyser")

-- loot
require("prototypes.resources.hog-remains")
require("prototypes.resources.plasma-spitter-remains")
require("prototypes.resources.stinger-remains")
require("prototypes.resources.hatcher-remains")
require("prototypes.resources.beryl-nut")
require("prototypes.resources.paleberry")
require("prototypes.resources.bacon-agaric")

data:extend{
	{type="recipe-category",name="resource-scanner"},
	{type="resource-category",name="solid"},
	{type="resource-category",name="water"},
	{type="resource-category",name="crude-oil"},
	{type="resource-category",name="resource-well"},
	{type="resource-category",name="resource-node"},
	{type="resource-category",name="geothermal"}
}
