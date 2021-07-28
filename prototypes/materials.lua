require("prototypes.materials.biomass")
require("prototypes.materials.solid-biofuel")
require("prototypes.materials.liquid-biofuel")
require("prototypes.materials.iron-ingot")
require("prototypes.materials.iron-plate")
require("prototypes.materials.iron-rod")
require("prototypes.materials.screw")
require("prototypes.materials.reinforced-iron-plate")
require("prototypes.materials.copper-ingot")
require("prototypes.materials.wire")
require("prototypes.materials.copper-cable")
require("prototypes.materials.copper-sheet")
require("prototypes.materials.copper-powder")
require("prototypes.materials.concrete")
require("prototypes.materials.steel-ingot")
require("prototypes.materials.steel-beam")
require("prototypes.materials.steel-pipe")
require("prototypes.materials.encased-industrial-beam")
require("prototypes.materials.rotor")
require("prototypes.materials.stator")
require("prototypes.materials.motor")
require("prototypes.materials.modular-frame")
require("prototypes.materials.heavy-modular-frame")
require("prototypes.materials.fused-modular-frame")
require("prototypes.materials.pressure-conversion-cube")
require("prototypes.materials.heavy-oil")
require("prototypes.materials.polymer-resin")
require("prototypes.materials.fuel")
require("prototypes.materials.turbofuel")
require("prototypes.materials.compacted-coal")
require("prototypes.materials.petroleum-coke")
require("prototypes.materials.fabric")
require("prototypes.materials.plastic")
require("prototypes.materials.rubber")
require("prototypes.materials.circuit-board")
require("prototypes.materials.high-speed-connector")
require("prototypes.materials.ai-limiter")
require("prototypes.materials.computer")
require("prototypes.materials.supercomputer")
require("prototypes.materials.caterium-ingot")
require("prototypes.materials.quickwire")
require("prototypes.materials.silica")
require("prototypes.materials.alumina-solution")
require("prototypes.materials.aluminium-scrap")
require("prototypes.materials.aluminium-ingot")
require("prototypes.materials.alclad-aluminium-sheet")
require("prototypes.materials.aluminium-casing")
require("prototypes.materials.quartz-crystal")
require("prototypes.materials.crystal-oscillator")
require("prototypes.materials.heat-sink")
require("prototypes.materials.cooling-system")
require("prototypes.materials.radio-control-unit")
require("prototypes.materials.turbo-motor")
require("prototypes.materials.black-powder")
require("prototypes.materials.sulfuric-acid")
require("prototypes.materials.nitric-acid")
require("prototypes.materials.battery")
require("prototypes.materials.encased-uranium-cell")
require("prototypes.materials.electromagnetic-control-rod")
require("prototypes.materials.uranium-fuel-rod")
require("prototypes.materials.uranium-waste")
require("prototypes.materials.non-fissile-uranium")
require("prototypes.materials.plutonium-pellet")
require("prototypes.materials.encased-plutonium-cell")
require("prototypes.materials.plutonium-fuel-rod")
require("prototypes.materials.plutonium-waste")
require("prototypes.materials.smart-plating")
require("prototypes.materials.versatile-framework")
require("prototypes.materials.automated-wiring")
require("prototypes.materials.modular-engine")
require("prototypes.materials.adaptive-control-unit")
require("prototypes.materials.assembly-director-system")
require("prototypes.materials.magnetic-field-generator")
require("prototypes.materials.thermal-propulsion-rocket")
require("prototypes.materials.nuclear-pasta")
require("prototypes.materials.packaged-fluids")

data:extend{
	{type="item-subgroup",group="intermediate-products",name="organic-resource",order="s-a"},
	{type="item-subgroup",group="intermediate-products",name="mineral-resource",order="s-b"},
	{type="item-subgroup",group="intermediate-products",name="ingots",order="s-c"},
	{type="item-subgroup",group="intermediate-products",name="parts",order="s-d"},
	{type="item-subgroup",group="intermediate-products",name="components",order="s-e"},
	{type="item-subgroup",group="intermediate-products",name="nuclear",order="s-f"},
	{type="item-subgroup",group="intermediate-products",name="fluid-recipe",order="s-o"},
	{type="item-subgroup",group="intermediate-products",name="packed-fluid",order="s-p"},
	{type="item-subgroup",group="intermediate-products",name="unpack-fluid",order="s-q"},
	{type="item-subgroup",group="fluids",name="fluid-resource",order="s-a"},
	{type="item-subgroup",group="fluids",name="fluid-product",order="s-b"},
	{type="item-subgroup",group="fluids",name="fluid-fuel",order="s-c"},

	{type="fuel-category",name="carbon"}, -- coal, compacted coal, coke
	{type="fuel-category",name="packaged-fuel"}, -- packaged fuel, packaged turbofuel, packaged heavy oil residue, packaged oil
	{type="fuel-category",name="battery"}, -- batteries
	{
		filename = "__base__/graphics/icons/tooltips/tooltip-category-chemical.png",
		flags = {"gui-icon"},
		height = 40,
		mipmap_count = 2,
		name = "tooltip-category-carbon",
		priority = "extra-high-no-scale",
		scale = 0.5,
		type = "sprite",
		width = 40
	},
	{
		filename = "__base__/graphics/icons/tooltips/tooltip-category-water.png",
		flags = {"gui-icon"},
		height = 40,
		mipmap_count = 2,
		name = "tooltip-category-liquid-fuel",
		priority = "extra-high-no-scale",
		scale = 0.5,
		type = "sprite",
		width = 40
	},
	{
		filename = graphics.."icons/tooltip-category-packaged-fuel.png",
		flags = {"gui-icon"},
		height = 40,
		mipmap_count = 2,
		name = "tooltip-category-packaged-fuel",
		priority = "extra-high-no-scale",
		scale = 0.5,
		type = "sprite",
		width = 40
	}
}
