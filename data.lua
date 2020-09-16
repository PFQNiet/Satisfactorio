data:extend({
	{type="ammo-category",name="infinite"},
	{type="ammo-category",name="solid-biofuel"}, -- for the Chainsaw
	{type="fuel-category",name="carbon"}, -- coal, compacted coal, coke
	{type="fuel-category",name="liquid-fuel"}, -- liquid biofuel, fuel, turbofuel
	{type="fuel-category",name="packaged-fuel"}, -- packaged fuel
	{type="fuel-category",name="packaged-alt-fuel"}, -- packaged turbofuel, packaged heavy oil residue, packaged oil, battery
	{type="resource-category",name="solid"},
	{type="resource-category",name="water"},
	{type="resource-category",name="crude-oil"},
	{type="recipe-category",name="nil"},
	{type="recipe-category",name="craft-bench"},
	{type="recipe-category",name="building"},
	{type="recipe-category",name="unbuilding"},
	{type="recipe-category",name="equipment"},
	{type="recipe-category",name="smelter"},
	{type="recipe-category",name="foundry"},
	{type="recipe-category",name="constructing"},
	{type="recipe-category",name="assembling"},
	{type="recipe-category",name="manufacturing"},
	{type="recipe-category",name="refining"},
	{type="recipe-category",name="resource-scanner"},
	{type="recipe-category",name="hub-progressing"},
	{type="recipe-category",name="space-elevator"},
	{type="recipe-category",name="mam-research"},
	{type="recipe-category",name="coal-generator"},
	{type="item-group",name="special",order="a",icon="__base__/graphics/item-group/effects.png",icon_size=64},
	{type="item-group",name="milestones",order="h",icon="__Satisfactorio__/graphics/icons/the-hub.png",icon_size=64},
	{type="item-group",name="space-elevator",order="i",icon="__Satisfactorio__/graphics/icons/space-elevator.png",icon_size=64},
	{type="item-subgroup",group="special",name="special",order="s-a-a"},
	{type="item-subgroup",group="special",name="special-undo",order="s-b-a"},
	{type="item-subgroup",group="logistics",name="logistics-balancing",order="s-a-a"},
	{type="item-subgroup",group="logistics",name="logistics-observation",order="s-a-b"},
	{type="item-subgroup",group="logistics",name="logistics-wall",order="s-a-c"},
	{type="item-subgroup",group="logistics",name="logistics-undo",order="s-undo"},
	{type="item-subgroup",group="production",name="production-power",order="s-a-a"},
	{type="item-subgroup",group="production",name="production-fluid",order="s-a-b"},
	{type="item-subgroup",group="production",name="production-manufacturer",order="s-a-c"},
	{type="item-subgroup",group="production",name="production-miner",order="s-a-d"},
	{type="item-subgroup",group="production",name="production-smelter",order="s-a-e"},
	{type="item-subgroup",group="production",name="production-workstation",order="s-a-f"},
	{type="item-subgroup",group="production",name="production-undo",order="s-undo"},
	{type="item-subgroup",group="intermediate-products",name="organic-resource",order="a"},
	{type="item-subgroup",group="intermediate-products",name="components",order="g"},
	{type="item-subgroup",group="milestones",name="hub-tier0",order="a"},
	{type="item-subgroup",group="milestones",name="hub-tier1",order="b"},
	{type="item-subgroup",group="milestones",name="hub-tier2",order="c"},
	{type="item-subgroup",group="milestones",name="hub-tier3",order="d"},
	{type="item-subgroup",group="milestones",name="hub-tier4",order="e"},
	{type="item-subgroup",group="milestones",name="hub-tier5",order="f"},
	{type="item-subgroup",group="milestones",name="hub-tier6",order="g"},
	{type="item-subgroup",group="milestones",name="hub-tier7",order="h"},
	{type="item-subgroup",group="space-elevator",name="space-parts",order="a"}
})
table.insert(data.raw['god-controller'].default.crafting_categories, "building")
table.insert(data.raw['god-controller'].default.crafting_categories, "unbuilding")
table.insert(data.raw['god-controller'].default.mining_categories, "solid")

require("prototypes.fonts")
require("prototypes.vanilla-cleanup")
require("prototypes.character")
require("prototypes.creatures")
require("prototypes.resources")
require("prototypes.resource-scanner")
require("prototypes.materials")
require("prototypes.special")
require("prototypes.power")
require("prototypes.logistics")
require("prototypes.organisation")
require("prototypes.miners")
require("prototypes.constructors")
require("prototypes.vehicles")
require("prototypes.weapons")
require("prototypes.technology")
require("prototypes.map-tweaks")

data:extend({
	{
		type = "sound",
		name = "power-startup",
		filename = "__base__/sound/nightvision-on.ogg"
	},
	{
		type = "sound",
		name = "power-failure",
		filename = "__base__/sound/nightvision-off.ogg"
	},
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
		filename = "__base__/graphics/icons/tooltips/tooltip-category-chemical.png",
		flags = {"gui-icon"},
		height = 40,
		mipmap_count = 2,
		name = "tooltip-category-solid-biofuel",
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
		filename = "__Satisfactorio__/graphics/icons/tooltip-category-packaged-fuel.png",
		flags = {"gui-icon"},
		height = 40,
		mipmap_count = 2,
		name = "tooltip-category-packaged-fuel",
		priority = "extra-high-no-scale",
		scale = 0.5,
		type = "sprite",
		width = 40
	},
	{
		filename = "__Satisfactorio__/graphics/icons/tooltip-category-packaged-fuel.png",
		flags = {"gui-icon"},
		height = 40,
		mipmap_count = 2,
		name = "tooltip-category-packaged-alt-fuel",
		priority = "extra-high-no-scale",
		scale = 0.5,
		type = "sprite",
		width = 40
	}
})
