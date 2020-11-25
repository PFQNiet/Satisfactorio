modpath = "__Satisfactorio__."
foundation_layer = require("collision-mask-util").get_first_unused_layer()
data:extend({
	{type="ammo-category",name="rebar"},
	{type="ammo-category",name="infinite"},
	{type="ammo-category",name="solid-biofuel"}, -- for the Chainsaw
	{type="fuel-category",name="carbon"}, -- coal, compacted coal, coke
	{type="fuel-category",name="liquid-fuel"}, -- liquid biofuel, fuel, turbofuel
	{type="fuel-category",name="packaged-fuel"}, -- packaged fuel
	{type="fuel-category",name="packaged-alt-fuel"}, -- packaged turbofuel, packaged heavy oil residue, packaged oil, battery
	{type="resource-category",name="solid"},
	{type="resource-category",name="water"},
	{type="resource-category",name="crude-oil"},
	{type="resource-category",name="geothermal"},
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
	{type="recipe-category",name="packaging"},
	{type="recipe-category",name="resource-scanner"},
	{type="recipe-category",name="object-scanner"},
	{type="recipe-category",name="hub-progressing"},
	{type="recipe-category",name="space-elevator"},
	{type="recipe-category",name="mam"},
	{type="recipe-category",name="awesome-shop"},
	{type="recipe-category",name="coal-generator"},
	{type="recipe-category",name="nuclear-power"},
	{type="item-group",name="special",order="91",icon="__Satisfactorio__/graphics/item-group/special.png",icon_size=64},
	{type="item-group",name="milestones",order="92",icon="__Satisfactorio__/graphics/icons/the-hub.png",icon_size=64},
	{type="item-group",name="space-elevator",order="x3",icon="__Satisfactorio__/graphics/icons/space-elevator.png",icon_size=64},
	{type="item-group",name="mam-research",order="x4",icon="__Satisfactorio__/graphics/icons/mam.png",icon_size=64},
	{type="item-subgroup",group="special",name="special",order="s-a"},
	{type="item-subgroup",group="special",name="special-undo",order="s-undo"},
	{type="item-subgroup",group="logistics",name="logistics-observation",order="s-b"},
	{type="item-subgroup",group="logistics",name="logistics-wall",order="s-c"},
	{type="item-subgroup",group="logistics",name="transport-player",order="dz"},
	{type="item-subgroup",group="logistics",name="logistics-undo",order="s-undo"},
	{type="item-subgroup",group="production",name="production-power",order="s-a"},
	{type="item-subgroup",group="production",name="production-fluid",order="s-b"},
	{type="item-subgroup",group="production",name="production-manufacturer",order="s-c"},
	{type="item-subgroup",group="production",name="production-miner",order="s-d"},
	{type="item-subgroup",group="production",name="production-smelter",order="s-e"},
	{type="item-subgroup",group="production",name="production-workstation",order="s-f"},
	{type="item-subgroup",group="production",name="production-undo",order="s-undo"},
	{type="item-subgroup",group="intermediate-products",name="organic-resource",order="s-a"},
	{type="item-subgroup",group="intermediate-products",name="mineral-resource",order="s-b"},
	{type="item-subgroup",group="intermediate-products",name="ingots",order="s-c"},
	{type="item-subgroup",group="intermediate-products",name="parts",order="s-d"},
	{type="item-subgroup",group="intermediate-products",name="components",order="s-e"},
	{type="item-subgroup",group="intermediate-products",name="packed-fluid",order="s-p"},
	{type="item-subgroup",group="intermediate-products",name="unpack-fluid",order="s-q"},
	{type="item-subgroup",group="intermediate-products",name="nuclear",order="s-u"},
	{type="item-subgroup",group="combat",name="melee",order="9"},
	{type="item-subgroup",group="fluids",name="fluid-resource",order="s-a"},
	{type="item-subgroup",group="fluids",name="fluid-product",order="s-b"},
	{type="item-subgroup",group="fluids",name="fluid-fuel",order="s-c"},
	{type="item-subgroup",group="milestones",name="hub-tier0",order="a"},
	{type="item-subgroup",group="milestones",name="hub-tier1",order="b"},
	{type="item-subgroup",group="milestones",name="hub-tier2",order="c"},
	{type="item-subgroup",group="milestones",name="hub-tier3",order="d"},
	{type="item-subgroup",group="milestones",name="hub-tier4",order="e"},
	{type="item-subgroup",group="milestones",name="hub-tier5",order="f"},
	{type="item-subgroup",group="milestones",name="hub-tier6",order="g"},
	{type="item-subgroup",group="milestones",name="hub-tier7",order="h"},
	{type="item-subgroup",group="space-elevator",name="space-parts",order="a"},
	{type="item-subgroup",group="mam-research",name="mam-hard-drive",order="a"},
	{type="item-subgroup",group="mam-research",name="mam-alien-organisms",order="b"},
	{type="item-subgroup",group="mam-research",name="mam-caterium",order="c"},
	{type="item-subgroup",group="mam-research",name="mam-flower-petals",order="d"},
	{type="item-subgroup",group="mam-research",name="mam-mycelia",order="e"},
	{type="item-subgroup",group="mam-research",name="mam-nutrients",order="f"},
	{type="item-subgroup",group="mam-research",name="mam-power-slugs",order="g"},
	{type="item-subgroup",group="mam-research",name="mam-quartz",order="h"},
	{type="item-subgroup",group="mam-research",name="mam-sulfur",order="i"}
})
data.raw['item-subgroup']['transport'].order = "e"
data.raw['item-subgroup']['train-transport'].order = "f"
local igroups = data.raw['item-group']
for _,key in pairs({"logistics","production","intermediate-products","combat"}) do
	local igroup = igroups[key]
	igroup.icon = "__Satisfactorio__/graphics/item-group/"..key..".png"
	igroup.icon_size = 64
	igroup.icon_mipmaps = 1
end
table.insert(data.raw['god-controller'].default.crafting_categories, "building")
table.insert(data.raw['god-controller'].default.crafting_categories, "unbuilding")
table.insert(data.raw['god-controller'].default.mining_categories, "solid")
data.raw['god-controller'].default.mining_speed = 2

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
require("prototypes.equipment")
require("prototypes.radioactivity")
require("prototypes.technology")
require("prototypes.map-tweaks")
require("prototypes.tips-and-tricks")
local find_logo = [[
	local logo = game.surfaces.nauvis.find_entities_filtered{name="factorio-logo-11tiles",limit=1}[1]
	game.camera_position = {logo.position.x, logo.position.y+9.75}
	game.camera_zoom = 1
	game.tick_paused = false
	game.surfaces.nauvis.daytime = 0
]]
data.raw['utility-constants'].default.main_menu_simulations = {
	plastic = {
		checkboard = false,
		save = "__Satisfactorio__/menu-simulations/plastic.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	},
	coal_power = {
		checkboard = false,
		save = "__Satisfactorio__/menu-simulations/coal-power.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	},
	self_driving = {
		checkboard = false,
		save = "__Satisfactorio__/menu-simulations/self-driving.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	}
}

require("compatibility")

for _,fluid in pairs(data.raw.fluid) do
	fluid.auto_barrel = false
end

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
	},
	{
		type = "custom-input",
		name = "recipe-browser",
		key_sequence = "X",
		order = "a",
		consuming = "game-only",
		action = "lua"
	},
	{
		type = "shortcut",
		name = "recipe-browser",
		action = "lua",
		associated_control_input = "recipe-browser",
		icon = {
			filename = "__core__/graphics/icons/mip/list-view.png",
			size = 32,
			mipmap_count = 2
		},
		order = "s-a[recipe-browser]"
	}
})
