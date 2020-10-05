local lab = assert(data.raw.lab.omnilab, "Technology must be loaded AFTER the Omnilab")

local function addTech(name, icon, category, subgroup, order, time, prerequisites, ingredients, effects)
	table.insert(lab.inputs, name)
	data:extend({
		{
			type = "tool",
			name = name,
			subgroup = subgroup,
			order = order,
			icons = {{
				icon = "__Satisfactorio__/graphics/technology/"..icon..".png",
				icon_size = 256,
				scale = 0.25
			}},
			stack_size = 1,
			durability = 1,
			flags = {"hidden"}
		},
		{
			type = "recipe",
			name = name,
			ingredients = ingredients,
			result = name,
			energy_required = time,
			category = category,
			allow_intermediates = false,
			allow_as_intermediate = false,
			hide_from_stats = true,
			hide_from_player_crafting = true,
			enabled = false,
			overload_multiplier = 1,
			icon_size = 64,
			icons = {
				{
					icon = "__base__/graphics/icons/blueprint.png"
				},
				{
					icon = "__Satisfactorio__/graphics/technology/"..icon..".png",
					icon_size = 256,
					scale = 0.1
				}
			}
		},
		{
			type = "recipe",
			name = name.."-done",
			ingredients = ingredients,
			result = name,
			energy_required = time,
			category = category,
			allow_intermediates = false,
			allow_as_intermediate = false,
			hide_from_stats = true,
			hide_from_player_crafting = true,
			enabled = false,
			icon_size = 64,
			icons = {
				{
					icon = "__base__/graphics/icons/upgrade-planner.png"
				},
				{
					icon = "__Satisfactorio__/graphics/technology/"..icon..".png",
					icon_size = 256,
					scale = 0.1
				},
				{
					icon = "__base__/graphics/icons/checked-green.png",
					icon_size = 64,
					icon_mipmaps = 4,
					scale = 0.25,
					shift = {8,-8}
				}
			}
		},
		{
			type = "technology",
			name = name,
			order = order,
			icon = "__Satisfactorio__/graphics/technology/"..icon..".png",
			icon_size = 256,
			prerequisites = prerequisites,
			unit = {
				count = 1,
				time = time,
				ingredients = {{name,1}},
			},
			effects = effects
		}
	})
end

data:extend({
	{
		type = "technology",
		name = "the-hub",
		order = "a",
		icon = "__Satisfactorio__/graphics/technology/hub/the-hub.png",
		icon_size = 256,
		unit = {
			count = 1,
			time = 1,
			ingredients = {{"hub-parts",1}},
		},
		effects = {}
	},
	{
		icon = "__Satisfactorio__/graphics/icons/hub-parts.png",
		icon_size = 64,
		name = "hub-parts",
		order = "a[hub-parts]",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	}
})

addTech("hub-tier0-hub-upgrade-1", "hub/hub-upgrade-1-2", "hub-progressing", "hub-tier0", "a-0-1", 1, {"the-hub"}, {
	{"iron-stick",10}
}, {
	{type="unlock-recipe",recipe="equipment-workshop"},
	{type="unlock-recipe",recipe="portable-miner"},
	{type="character-inventory-slots-bonus",modifier=3},
	{type="nothing",effect_description={"technology-effect.add-storage-to-hub"}}
})
data.raw.recipe['hub-tier0-hub-upgrade-1'].enabled = true
addTech("hub-tier0-hub-upgrade-2", "hub/hub-upgrade-1-2", "hub-progressing", "hub-tier0", "a-0-2", 1, {"hub-tier0-hub-upgrade-1"}, {
	{"iron-stick",20},
	{"iron-plate",10}
}, {
	{type="unlock-recipe",recipe="smelter"},
	{type="unlock-recipe",recipe="copper-ingot"},
	{type="unlock-recipe",recipe="wire"},
	{type="unlock-recipe",recipe="copper-cable"},
	{type="unlock-recipe",recipe="scanner-copper-ore"},
	{type="nothing",effect_description={"technology-effect.add-biomass-burner-to-hub"}}
})
addTech("hub-tier0-hub-upgrade-3", "hub/hub-upgrade-3", "hub-progressing", "hub-tier0", "a-0-3", 1, {"hub-tier0-hub-upgrade-2"}, {
	{"iron-plate",20},
	{"iron-stick",20},
	{"wire",20}
}, {
	{type="unlock-recipe",recipe="constructor"},
	{type="unlock-recipe",recipe="small-electric-pole"},
	{type="unlock-recipe",recipe="concrete"},
	{type="unlock-recipe",recipe="screw"},
	{type="unlock-recipe",recipe="reinforced-iron-plate"},
	{type="unlock-recipe",recipe="scanner-stone"}
})
addTech("hub-tier0-hub-upgrade-4", "hub/hub-upgrade-4", "hub-progressing", "hub-tier0", "a-0-4", 1, {"hub-tier0-hub-upgrade-3"}, {
	{"iron-plate",75},
	{"copper-cable",20},
	{"concrete",10}
}, {
	{type="unlock-recipe",recipe="transport-belt"},
	{type="character-inventory-slots-bonus",modifier=3}
})
addTech("hub-tier0-hub-upgrade-5", "hub/hub-upgrade-5", "hub-progressing", "hub-tier0", "a-0-5", 1, {"hub-tier0-hub-upgrade-4"}, {
	{"iron-stick",75},
	{"copper-cable",50},
	{"concrete",20}
}, {
	{type="unlock-recipe",recipe="miner-mk-1"},
	{type="unlock-recipe",recipe="iron-chest"},
	{type="nothing",effect_description={"technology-effect.add-biomass-burner-to-hub"}}
})
addTech("hub-tier0-hub-upgrade-6", "hub/hub-upgrade-6", "hub-progressing", "hub-tier0", "a-0-6", 1, {"hub-tier0-hub-upgrade-5"}, {
	{"iron-stick",100},
	{"iron-plate",100},
	{"wire",100},
	{"concrete",50}
}, {
	{type="unlock-recipe",recipe="space-elevator"},
	{type="unlock-recipe",recipe="biomass-burner"},
	{type="unlock-recipe",recipe="biomass-from-leaves"},
	{type="unlock-recipe",recipe="biomass-from-wood"},
	{type="nothing",effect_description={"technology-effect.add-ficsit-freighter-to-hub"}}
})

addTech("hub-tier1-base-building", "hub/structure", "hub-progressing", "hub-tier1", "a-1-1", 120, {"hub-tier0-hub-upgrade-6"}, {
	{"concrete",200},
	{"iron-plate",100},
	{"iron-stick",100}
}, {
	{type="unlock-recipe",recipe="lookout-tower"},
	{type="unlock-recipe",recipe="foundation"},
	{type="unlock-recipe",recipe="stone-wall"}
})
addTech("hub-tier1-logistics-mk-1", "hub/logistics", "hub-progressing", "hub-tier1", "a-1-2", 240, {"hub-tier0-hub-upgrade-6"}, {
	{"iron-plate",150},
	{"iron-stick",150},
	{"wire",300}
}, {
	{type="unlock-recipe",recipe="conveyor-splitter"},
	{type="unlock-recipe",recipe="conveyor-merger"},
	{type="unlock-recipe",recipe="underground-belt"}
})
addTech("hub-tier1-field-research", "hub/equipment", "hub-progressing", "hub-tier1", "a-1-3", 180, {"hub-tier0-hub-upgrade-6"}, {
	{"wire",300},
	{"screw",300},
	{"iron-plate",100}
}, {
	{type="unlock-recipe",recipe="mam"},
	{type="unlock-recipe",recipe="wooden-chest"},
	{type="unlock-recipe",recipe="map-marker"},
	{type="unlock-recipe",recipe="object-scanner"},
	{type="character-inventory-slots-bonus",modifier=5}
})

addTech("hub-tier2-part-assembly", "hub/factory", "hub-progressing", "hub-tier2", "a-2-1", 360, {"hub-tier0-hub-upgrade-6"}, {
	{"iron-plate",300},
	{"iron-stick",200},
	{"screw",500},
	{"copper-cable",200}
}, {
	{type="unlock-recipe",recipe="assembler"},
	{type="unlock-recipe",recipe="copper-plate"},
	{type="unlock-recipe",recipe="rotor"},
	{type="unlock-recipe",recipe="modular-frame"},
	{type="unlock-recipe",recipe="smart-plating"}
})
addTech("hub-tier2-obstacle-clearing", "hub/equipment", "hub-progressing", "hub-tier2", "a-2-2", 180, {"hub-tier0-hub-upgrade-6"}, {
	{"screw",500},
	{"copper-cable",100},
	{"concrete",100}
}, {
	{type="unlock-recipe",recipe="solid-biofuel"},
	{type="unlock-recipe",recipe="chainsaw"},
	{type="character-inventory-slots-bonus",modifier=5}
})
addTech("hub-tier2-jump-pads", "hub/structure", "hub-progressing", "hub-tier2", "a-2-3", 240, {"hub-tier0-hub-upgrade-6"}, {
	{"rotor",50},
	{"iron-plate",300},
	{"copper-cable",150}
}, {
	-- {type="unlock-recipe",recipe="jump-pad"},
	-- {type="unlock-recipe",recipe="u-jelly-landing-pad"}
})
addTech("hub-tier2-resource-sink-bonus-program", "hub/factory", "hub-progressing", "hub-tier2", "a-2-4", 300, {"hub-tier0-hub-upgrade-6"}, {
	{"concrete",400},
	{"wire",500},
	{"iron-stick",200},
	{"iron-plate",200}
}, {
	{type="unlock-recipe",recipe="awesome-sink"},
	{type="unlock-recipe",recipe="awesome-shop"}
})
addTech("hub-tier2-logistics-mk-2", "hub/logistics", "hub-progressing", "hub-tier2", "a-2-5", 360, {"hub-tier0-hub-upgrade-6"}, {
	{"reinforced-iron-plate",50},
	{"concrete",200},
	{"iron-stick",300},
	{"iron-plate",300}
}, {
	{type="unlock-recipe",recipe="fast-transport-belt"},
	{type="unlock-recipe",recipe="fast-underground-belt"}
})

addTech("hub-tier3-coal-power", "hub/factory", "hub-progressing", "hub-tier3", "a-3-1", 480, {"space-elevator-phase1"}, {
	{"reinforced-iron-plate",150},
	{"rotor",50},
	{"copper-cable",300}
}, {
	{type="unlock-recipe",recipe="coal-generator"},
	{type="unlock-recipe",recipe="water-extractor"},
	{type="unlock-recipe",recipe="pipe"},
	{type="unlock-recipe",recipe="pipe-to-ground"},
	{type="unlock-recipe",recipe="pump"},
	{type="unlock-recipe",recipe="fluid-buffer"},
	{type="unlock-recipe",recipe="scanner-coal"}
})
addTech("hub-tier3-vehicular-transport", "hub/vehicle", "hub-progressing", "hub-tier3", "a-3-2", 240, {"space-elevator-phase1"}, {
	{"modular-frame",25},
	{"rotor",100},
	{"copper-cable",200},
	{"iron-stick",400}
}, {
	{type="unlock-recipe",recipe="truck-station"},
	{type="unlock-recipe",recipe="tractor"}
})
addTech("hub-tier3-basic-steel-production", "hub/factory", "hub-progressing", "hub-tier3", "a-3-3", 480, {"space-elevator-phase1"}, {
	{"modular-frame",50},
	{"rotor",150},
	{"concrete",300},
	{"wire",1000}
}, {
	{type="unlock-recipe",recipe="foundry"},
	{type="unlock-recipe",recipe="steel-ingot"},
	{type="unlock-recipe",recipe="steel-plate"},
	{type="unlock-recipe",recipe="steel-pipe"},
	{type="unlock-recipe",recipe="versatile-framework"}
})
addTech("hub-tier4-advanced-steel-production", "hub/factory", "hub-progressing", "hub-tier4", "a-4-1", 600, {"space-elevator-phase1"}, {
	{"steel-pipe",200},
	{"rotor",200},
	{"wire",1500},
	{"concrete",300}
}, {
	{type="unlock-recipe",recipe="miner-mk-2"},
	{type="unlock-recipe",recipe="encased-industrial-beam"},
	{type="unlock-recipe",recipe="stator"},
	{type="unlock-recipe",recipe="motor"},
	{type="unlock-recipe",recipe="automated-wiring"},
	{type="unlock-recipe",recipe="heavy-modular-frame"}
})
addTech("hub-tier4-improved-melee-combat", "hub/equipment", "hub-progressing", "hub-tier4", "a-4-2", 180, {"space-elevator-phase1"}, {
	{"rotor",25},
	{"reinforced-iron-plate",50},
	{"wire",1500},
	{"copper-cable",200}
}, {
	{type="unlock-recipe",recipe="xeno-basher"},
	{type="character-inventory-slots-bonus",modifier=5}
})
addTech("hub-tier4-hyper-tubes", "hub/structure", "hub-progressing", "hub-tier4", "a-4-3", 600, {"space-elevator-phase1"}, {
	{"copper-plate",300},
	{"steel-pipe",300},
	{"encased-industrial-beam",50}
}, {
	-- {type="unlock-recipe",recipe="hyper-tube-entrance"},
	-- {type="unlock-recipe",recipe="hyper-tube"},
	-- {type="unlock-recipe",recipe="underground-hyper-tube"}
})
addTech("hub-tier4-logistics-mk-3", "hub/logistics", "hub-progressing", "hub-tier4", "a-4-4", 300, {"space-elevator-phase1"}, {
	{"steel-plate",200},
	{"steel-pipe",100},
	{"concrete",500}
}, {
	{type="unlock-recipe",recipe="steel-chest"},
	{type="unlock-recipe",recipe="express-transport-belt"},
	{type="unlock-recipe",recipe="express-underground-belt"}
})

addTech("hub-tier5-oil-processing", "hub/factory", "hub-progressing", "hub-tier5", "a-5-1", 720, {"space-elevator-phase2"}, {
	{"motor",50},
	{"encased-industrial-beam",100},
	{"steel-pipe",500},
	{"copper-plate",500}
}, {
	{type="unlock-recipe",recipe="oil-extractor"},
	{type="unlock-recipe",recipe="refinery"},
	{type="unlock-recipe",recipe="plastic-bar"},
	{type="unlock-recipe",recipe="rubber"},
	{type="unlock-recipe",recipe="fuel"},
	{type="unlock-recipe",recipe="petroleum-coke"},
	{type="unlock-recipe",recipe="electronic-circuit"},
	{type="unlock-recipe",recipe="scanner-crude-oil"}
})
addTech("hub-tier5-industrial-manufacturing", "hub/factory", "hub-progressing", "hub-tier5", "a-5-2", 720, {"space-elevator-phase2"}, {
	{"motor",100},
	{"plastic-bar",200},
	{"rubber",200},
	{"copper-cable",1000}
}, {
	{type="unlock-recipe",recipe="manufacturer"},
	{type="unlock-recipe",recipe="truck"},
	{type="unlock-recipe",recipe="computer"},
	{type="unlock-recipe",recipe="modular-engine"},
	{type="unlock-recipe",recipe="adaptive-control-unit"}
})
addTech("hub-tier5-alternative-fluid-transport", "hub/logistics", "hub-progressing", "hub-tier5", "a-5-3", 480, {"space-elevator-phase2"}, {
	{"heavy-modular-frame",25},
	{"motor",100},
	{"plastic-bar",200},
	{"wire",3000}
}, {
	{type="unlock-recipe",recipe="industrial-fluid-buffer"},
	{type="unlock-recipe",recipe="empty-canister"},
	{type="unlock-recipe",recipe="packaged-water"},
	{type="unlock-recipe",recipe="packaged-oil"},
	{type="unlock-recipe",recipe="packaged-heavy-oil"},
	{type="unlock-recipe",recipe="packaged-fuel"},
	{type="unlock-recipe",recipe="packaged-liquid-biofuel"},
	{type="unlock-recipe",recipe="liquid-biofuel"}
})
addTech("hub-tier5-gas-mask", "hub/equipment", "hub-progressing", "hub-tier5", "a-5-4", 300, {"space-elevator-phase2"}, {
	{"rubber",200},
	{"plastic-bar",100},
	{"fabric",50}
}, {
	-- {type="unlock-recipe",recipe="gas-mask"},
	-- {type="unlock-recipe",recipe="gas-filter"}
})
addTech("hub-tier6-expanded-power-infrastructure", "hub/logistics", "hub-progressing", "hub-tier6", "a-6-1", 900, {"space-elevator-phase2"}, {
	{"heavy-modular-frame",50},
	{"computer",100},
	{"encased-industrial-beam",200},
	{"rubber",400}
}, {
	{type="unlock-recipe",recipe="fuel-generator"},
	{type="unlock-recipe",recipe="turbo-transport-belt"},
	{type="unlock-recipe",recipe="turbo-underground-belt"},
	{type="unlock-recipe",recipe="scanner-caterium-ore"}
})
addTech("hub-tier6-jetpack", "hub/equipment", "hub-progressing", "hub-tier6", "a-6-2", 300, {"space-elevator-phase2"}, {
	{"computer",25},
	{"motor",100},
	{"plastic-bar",200},
	{"rubber",200}
}, {
	-- {type="unlock-recipe",recipe="jetpack"},
	{type="character-inventory-slots-bonus",modifier=5}
})
addTech("hub-tier6-monorail-train-technology", "hub/vehicle", "hub-progressing", "hub-tier6", "a-6-3", 900, {"space-elevator-phase2"}, {
	{"computer",50},
	{"heavy-modular-frame",100},
	{"steel-plate",500},
	{"steel-pipe",600}
}, {
	-- {type="unlock-recipe",recipe="rail"},
	-- {type="unlock-recipe",recipe="train-station"},
	-- {type="unlock-recipe",recipe="freight-platform"},
	-- {type="unlock-recipe",recipe="fluid-freight-platform"},
	-- {type="unlock-recipe",recipe="empty-platform"},
	-- {type="unlock-recipe",recipe="locomotive"},
	-- {type="unlock-recipe",recipe="cargo-wagon"},
	-- {type="unlock-recipe",recipe="fluid-wagon"}
})

addTech("hub-tier7-bauxite-refinement", "hub/factory", "hub-progressing", "hub-tier7", "a-7-1", 900, {"space-elevator-phase3"}, {
	{"motor",200},
	{"computer",100},
	{"heavy-modular-frame",100}
}, {
	{type="unlock-recipe",recipe="ultimate-transport-belt"},
	{type="unlock-recipe",recipe="ultimate-underground-belt"},
	{type="unlock-recipe",recipe="alumina-solution"},
	{type="unlock-recipe",recipe="aluminium-scrap"},
	{type="unlock-recipe",recipe="aluminium-ingot"},
	{type="unlock-recipe",recipe="alclad-aluminium-sheet"},
	{type="unlock-recipe",recipe="scanner-bauxite"},
	{type="unlock-recipe",recipe="scanner-raw-quartz"}
})
addTech("hub-tier7-advanced-aluminium-production", "hub/factory", "hub-progressing", "hub-tier7", "a-7-2", 900, {"space-elevator-phase3"}, {
	{"alclad-aluminium-sheet",200},
	{"motor",300},
	{"heavy-modular-frame",150},
	{"computer",150}
}, {
	{type="unlock-recipe",recipe="miner-mk-3"},
	{type="unlock-recipe",recipe="heat-sink"},
	{type="unlock-recipe",recipe="turbo-motor"},
	{type="unlock-recipe",recipe="battery"}
})
addTech("hub-tier7-hazmat-suit", "hub/equipment", "hub-progressing", "hub-tier7", "a-7-3", 300, {"space-elevator-phase3"}, {
	{"alclad-aluminium-sheet",100},
	{"quickwire",100},
	{"rubber",500}
}, {
	-- {type="unlock-recipe",recipe="hazmat-suit"},
	-- {type="unlock-recipe",recipe="iodine-infused-filter"}
})
addTech("hub-tier7-nuclear-power", "hub/factory", "hub-progressing", "hub-tier7", "a-7-4", 1200, {"space-elevator-phase3"}, {
	{"processing-unit",50},
	{"advanced-circuit",50},
	{"heavy-modular-frame",200},
	{"computer",200}
}, {
	{type="unlock-recipe",recipe="nuclear-power-plant"},
	{type="unlock-recipe",recipe="sulfuric-acid"},
	{type="unlock-recipe",recipe="uranium-pellet"},
	{type="unlock-recipe",recipe="uranium-fuel-cell"},
	{type="unlock-recipe",recipe="electromagnetic-control-rod"},
	{type="unlock-recipe",recipe="nuclear-fuel"},
	{type="unlock-recipe",recipe="scanner-uranium-ore"},
	{type="unlock-recipe",recipe="scanner-sulfur"}
})

--[[ SPACE ELEVATOR ]]--
addTech("space-elevator-phase1", "space/smart-plating", "space-elevator", "space-parts", "e-1", 1, {"hub-tier0-hub-upgrade-6"}, {
	{"smart-plating",50}
}, {
	-- HUB recipes are handled separately
})
addTech("space-elevator-phase2", "space/versatile-framework", "space-elevator", "space-parts", "e-2", 1, {"space-elevator-phase1"}, {
	{"smart-plating",500},
	{"versatile-framework",500},
	{"automated-wiring",100}
}, {})
addTech("space-elevator-phase3", "space/adaptive-control-unit", "space-elevator", "space-parts", "e-3", 1, {"space-elevator-phase2"}, {
	{"versatile-framework",2500},
	{"modular-engine",500},
	{"adaptive-control-unit",100}
})

--[[ MAM ]]--
addTech("mam-alien-organisms-alien-carapace", "mam/alien-carapace", "mam", "mam-alien-organisms", "m-1-1", 3, {"hub-tier1-field-research"}, {
	{"alien-carapace",1}
}, {})
addTech("mam-alien-organisms-structural-analysis", "mam/biomass", "mam", "mam-alien-organisms", "m-1-2", 3, {"mam-alien-organisms-alien-carapace"}, {
	{"alien-carapace",10}
}, {
	{type="unlock-recipe",recipe="biomass-from-alien-carapace"}
})
addTech("mam-alien-organisms-alien-organs", "mam/alien-organs", "mam", "mam-alien-organisms", "m-1-4", 3, {"hub-tier1-field-research"}, {
	{"alien-organs",1}
}, {})
addTech("mam-alien-organisms-organic-properties", "mam/biomass", "mam", "mam-alien-organisms", "m-1-5", 3, {"mam-alien-organisms-alien-organs"}, {
	{"alien-organs",3}
}, {
	{type="unlock-recipe",recipe="biomass-from-alien-organs"}
})
addTech("mam-alien-organisms-rebar-gun", "mam/rebar-gun", "mam", "mam-alien-organisms", "m-1-6", 300, {"mam-alien-organisms-structural-analysis"}, {
	{"reinforced-iron-plate",50},
	{"rotor",25},
	{"screw",500}
}, {
	{type="unlock-recipe",recipe="pistol"}
})
addTech("mam-alien-organisms-spiked-rebars", "mam/spiked-rebar", "mam", "mam-alien-organisms", "m-1-7", 3, {"mam-alien-organisms-rebar-gun"}, {
	{"rotor",25},
	{"iron-stick",200}
}, {
	{type="unlock-recipe",recipe="spiked-rebar"}
})
addTech("mam-alien-organisms-object-scanner-improvements", "mam/key", "mam", "mam-alien-organisms", "m-1-8", 3, {"mam-alien-organisms-structural-analysis","mam-alien-organisms-organic-properties"}, {
	{"crystal-oscillator",5},
	{"stator",10},
	{"object-scanner",1}
}, {})
addTech("mam-alien-organisms-hostile-organism-detection", "mam/enemies", "mam", "mam-alien-organisms", "m-1-9", 3, {"mam-alien-organisms-object-scanner-improvements"}, {
	{"alien-organs",5},
	{"alien-carapace",5}
}, {
	-- TODO Object Scanner enemies mode
})
addTech("mam-alien-organisms-medicinal-inhaler", "mam/medicinal-inhaler", "mam", "mam-alien-organisms", "m-1-a", 300, {"mam-alien-organisms-organic-properties"}, {
	{"alien-organs",5},
	{"mycelia",10},
	{"modular-frame",100}
}, {
	{type="unlock-recipe",recipe="medicinal-inhaler-from-alien-organs"}
})
addTech("mam-alien-organisms-inflated-pocket-dimension", "mam/thumbsup", "mam", "mam-alien-organisms", "m-1-b", 300, {"mam-alien-organisms-structural-analysis","mam-alien-organisms-organic-properties"}, {
	{"alien-carapace",5},
	{"alien-organs",5},
	{"wire",3000}
}, {
	{type="character-inventory-slots-bonus",modifier=5}
})

addTech("mam-caterium-caterium", "mam/caterium-ore", "mam", "mam-caterium", "m-2-1", 3, {"hub-tier1-field-research"}, {
	{"caterium-ore",10}
}, {
	{type="unlock-recipe",recipe="scanner-caterium-ore"}
})
addTech("mam-caterium-caterium-ingots", "mam/caterium-ingot", "mam", "mam-caterium", "m-2-2", 3, {"mam-caterium-caterium"}, {
	{"caterium-ore",50}
}, {
	{type="unlock-recipe",recipe="caterium-ingot"}
})
addTech("mam-caterium-quickwire", "mam/quickwire", "mam", "mam-caterium", "m-2-3", 3, {"mam-caterium-caterium-ingots"}, {
	{"caterium-ingot",50}
}, {
	{type="unlock-recipe",recipe="quickwire"}
})
addTech("mam-caterium-caterium-electronics", "mam/key", "mam", "mam-caterium", "m-2-4", 3, {"mam-caterium-quickwire"}, {
	{"quickwire",100}
}, {})
addTech("mam-caterium-inflated-pocket-dimension1", "mam/thumbsup", "mam", "mam-caterium", "m-2-5", 120, {"mam-caterium-quickwire"}, {
	{"quickwire",50},
	{"wire",500},
	{"reinforced-iron-plate",50}
}, {
	{type="character-inventory-slots-bonus",modifier=5}
})
addTech("mam-caterium-blade-runners", "mam/blade-runners", "mam", "mam-caterium", "m-2-6", 300, {"mam-caterium-caterium-electronics"}, {
	{"quickwire",100},
	{"modular-frame",10}
}, {
	{type="unlock-recipe",recipe="exoskeleton-equipment"}
})
addTech("mam-caterium-ai-limiter", "mam/ai-limiter", "mam", "mam-caterium", "m-2-7", 3, {"mam-caterium-caterium-electronics"}, {
	{"quickwire",200},
	{"copper-plate",50}
}, {
	{type="unlock-recipe",recipe="processing-unit"}
})
addTech("mam-caterium-power-poles-mk2", "mam/power-pole-mk2", "mam", "mam-caterium", "m-2-8", 300, {"mam-caterium-caterium-electronics"}, {
	{"quickwire",300}
}, {
	{type="unlock-recipe",recipe="medium-electric-pole"}
})
addTech("mam-caterium-smart-splitter", "mam/smart-splitter", "mam", "mam-caterium", "m-2-9", 3, {"mam-caterium-ai-limiter"}, {
	{"processing-unit",10},
	{"reinforced-iron-plate",50}
}, {
	-- {type="unlock-recipe",recipe="smart-splitter"}
})
addTech("mam-caterium-high-speed-connector", "mam/high-speed-connector", "mam", "mam-caterium", "m-2-a", 3, {"mam-caterium-ai-limiter"}, {
	{"quickwire",500},
	{"plastic-bar",50}
}, {
	{type="unlock-recipe",recipe="advanced-circuit"}
})
addTech("mam-caterium-inflated-pocket-dimension2", "mam/thumbsup", "mam", "mam-caterium", "m-2-b", 180, {"mam-caterium-high-speed-connector"}, {
	{"advanced-circuit",50},
	{"motor",50}
}, {
	{type="character-inventory-slots-bonus",modifier=5}
})
addTech("mam-caterium-supercomputer", "mam/supercomputer", "mam", "mam-caterium", "m-2-c", 3, {"mam-caterium-high-speed-connector"}, {
	{"processing-unit",50},
	{"advanced-circuit",50},
	{"computer",50}
}, {
	{type="unlock-recipe",recipe="supercomputer"}
})
addTech("mam-caterium-power-poles-mk3", "mam/power-pole-mk3", "mam", "mam-caterium", "m-2-d", 240, {"mam-caterium-high-speed-connector"}, {
	{"advanced-circuit",100},
	{"steel-pipe",200}
}, {
	{type="unlock-recipe",recipe="big-electric-pole"}
})
addTech("mam-caterium-programmable-splitter", "mam/programmable-splitter", "mam", "mam-caterium", "m-2-e", 480, {"mam-caterium-supercomputer"}, {
	{"supercomputer",50},
	{"heavy-modular-frame",50}
}, {
	-- {type="unlock-recipe",recipe="programmable-splitter"}
})
addTech("mam-caterium-geothermal-generator", "mam/geothermal-generator", "mam", "mam-caterium", "m-2-f", 480, {"mam-caterium-supercomputer"}, {
	{"supercomputer",50},
	{"heavy-modular-frame",50},
	{"rubber",300}
}, {
	-- {type="unlock-recipe",recipe="geothermal-generator"}
})

-- 3: flower petals

addTech("mam-mycelia-mycelia", "mam/mycelia", "mam", "mam-mycelia", "m-4-1", 3, {"hub-tier1-field-research"}, {
	{"mycelia",5}
}, {
	{type="unlock-recipe",recipe="biomass-from-mycelia"}
})
addTech("mam-mycelia-medical-properties", "mam/key", "mam", "mam-mycelia", "m-4-2", 3, {"mam-mycelia-mycelia"}, {
	{"bacon-agaric",1},
	{"paleberry",2},
	{"beryl-nut",3}
}, {})
addTech("mam-mycelia-medicinal-inhaler", "mam/medicinal-inhaler", "mam", "mam-mycelia", "m-4-3", 3, {"mam-mycelia-medical-properties"}, {
	{"mycelia",10},
	{"reinforced-iron-plate",25},
	{"rotor",25}
}, {
	{type="unlock-recipe",recipe="medicinal-inhaler"}
})
addTech("mam-mycelia-fabric", "mam/fabric", "mam", "mam-mycelia", "m-4-4", 3, {"mam-mycelia-mycelia"}, {
	{"mycelia",25},
	{"biomass",100}
}, {
	{type="unlock-recipe",recipe="fabric"}
})
--[[
addTech("mam-mycelia-parachute", "mam/parachute", "mam", "mam-mycelia", "m-4-5", 3, {"mam-mycelia-fabric"}, {
	{"fabric",10},
	{"cable",50}
}, {
	{type="unlock-recipe",recipe="parachute"}
})
]]

addTech("mam-nutrients-beryl-nut", "mam/beryl-nut", "mam", "mam-nutrients", "m-5-1", 180, {"hub-tier1-field-research"}, {
	{"beryl-nut",5}
}, {
	{type="unlock-recipe",recipe="scanner-beryl-nut"}
})
addTech("mam-nutrients-paleberry", "mam/paleberry", "mam", "mam-nutrients", "m-5-2", 180, {"hub-tier1-field-research"}, {
	{"paleberry",2}
}, {
	{type="unlock-recipe",recipe="scanner-paleberry"}
})
addTech("mam-nutrients-bacon-agaric", "mam/bacon-agaric", "mam", "mam-nutrients", "m-5-3", 180, {"hub-tier1-field-research"}, {
	{"bacon-agaric",1}
}, {
	{type="unlock-recipe",recipe="scanner-bacon-agaric"}
})
addTech("mam-nutrients-nutritional-mixture", "mam/key", "mam", "mam-nutrients", "m-5-4", 3, {"mam-nutrients-beryl-nut","mam-nutrients-paleberry","mam-nutrients-bacon-agaric"}, {
	{"stator",25},
	{"steel-pipe",100},
	{"wire",500}
}, {})
addTech("mam-nutrients-nutritional-inhaler", "mam/medicinal-inhaler", "mam", "mam-nutrients", "m-5-5", 3, {"mam-nutrients-nutritional-mixture"}, {
	{"bacon-agaric",2},
	{"paleberry",4},
	{"beryl-nut",10}
}, {
	{type="unlock-recipe",recipe="nutritional-inhaler"}
})

addTech("mam-power-slugs-overclocking", "mam/overclocking", "mam", "mam-power-slugs", "m-6-1", 300, {"hub-tier1-field-research"}, {
	{"iron-stick",50},
	{"iron-plate",50},
	{"wire",50}
}, {})
addTech("mam-power-slugs-green-power-slugs", "mam/green-power-slug", "mam", "mam-power-slugs", "m-6-2", 3, {"mam-power-slugs-overclocking"}, {
	{"green-power-slug",1}
}, {
	{type="unlock-recipe",recipe="power-shard-from-green-power-slug"}
})
addTech("mam-power-slugs-slug-scanning", "mam/green-power-slug", "mam", "mam-power-slugs", "m-6-3", 3, {"mam-power-slugs-green-power-slugs"}, {
	{"iron-stick",50},
	{"wire",100},
	{"copper-cable",50}
}, {
	{type="unlock-recipe",recipe="scanner-power-slugs"}
})
addTech("mam-power-slugs-yellow-power-slugs", "mam/yellow-power-slug", "mam", "mam-power-slugs", "m-6-4", 3, {"mam-power-slugs-green-power-slugs"}, {
	{"yellow-power-slug",1},
	{"reinforced-iron-plate",25},
	{"copper-cable",100}
}, {
	{type="unlock-recipe",recipe="power-shard-from-yellow-power-slug"}
})
addTech("mam-power-slugs-purple-power-slugs", "mam/purple-power-slug", "mam", "mam-power-slugs", "m-6-5", 3, {"mam-power-slugs-yellow-power-slugs"}, {
	{"purple-power-slug",1},
	{"modular-frame",25},
	{"copper-cable",200}
}, {
	{type="unlock-recipe",recipe="power-shard-from-purple-power-slug"}
})

addTech("mam-quartz-quartz", "mam/raw-quartz", "mam", "mam-quartz", "m-7-1", 3, {"hub-tier1-field-research"}, {
	{"raw-quartz",10}
}, {
	{type="unlock-recipe",recipe="scanner-raw-quartz"}
})
addTech("mam-quartz-silica", "mam/silica", "mam", "mam-quartz", "m-7-2", 3, {"mam-quartz-quartz"}, {
	{"raw-quartz",20}
}, {
	{type="unlock-recipe",recipe="silica"}
})
addTech("mam-quartz-quartz-crystals", "mam/quartz-crystal", "mam", "mam-quartz", "m-7-3", 3, {"mam-quartz-quartz"}, {
	{"raw-quartz",20}
}, {
	{type="unlock-recipe",recipe="quartz-crystal"}
})
addTech("mam-quartz-crystal-oscillator", "mam/crystal-oscillator", "mam", "mam-quartz", "m-7-4", 3, {"mam-quartz-quartz-crystals"}, {
	{"quartz-crystal",100},
	{"reinforced-iron-plate",50}
}, {
	{type="unlock-recipe",recipe="crystal-oscillator"}
})
addTech("mam-quartz-signal-technologies", "mam/key", "mam", "mam-quartz", "m-7-5", 3, {"mam-quartz-crystal-oscillator"}, {
	{"crystal-oscillator",5}
}, {})
addTech("mam-quartz-explorer", "mam/explorer", "mam", "mam-quartz", "m-7-6", 300, {"mam-quartz-signal-technologies"}, {
	{"crystal-oscillator",10},
	{"modular-frame",100}
}, {
	-- {type="unlock-recipe",recipe="explorer"}
})
addTech("mam-quartz-frequency-mapping", "mam/map", "mam", "mam-quartz", "m-7-7", 300, {"mam-quartz-signal-technologies"}, {
	{"crystal-oscillator",10},
	{"map-marker",10}
}, {
	{type="nothing",effect_description={"technology-effect.map"}}
})
addTech("mam-quartz-radio-signal-scanning", "mam/crash-site", "mam", "mam-quartz", "m-7-8", 300, {"mam-quartz-frequency-mapping"}, {
	{"crystal-oscillator",50},
	{"motor",100},
	{"map-marker",10}
}, {
	-- {type="unlock-recipe",recipe="scanner-crash-site"}
})
addTech("mam-quartz-radar-technology", "mam/radar-tower", "mam", "mam-quartz", "m-7-9", 3, {"mam-quartz-frequency-mapping"}, {
	{"crystal-oscillator",100},
	{"heavy-modular-frame",50},
	{"map-marker",15}
}, {
	{type="unlock-recipe",recipe="radar"}
})
addTech("mam-quartz-radio-control-unit", "mam/radio-control-unit", "mam", "mam-quartz", "m-7-a", 3, {"mam-quartz-signal-technologies"}, {
	{"crystal-oscillator",100},
	{"alclad-aluminium-sheet",200}
}, {
	{type="unlock-recipe",recipe="radio-control-unit"}
})

addTech("mam-sulfur-sulfur", "mam/sulfur", "mam", "mam-sulfur", "m-8-1", 3, {"hub-tier1-field-research"}, {
	{"sulfur",10}
}, {
	{type="unlock-recipe",recipe="scanner-sulfur"}
})
addTech("mam-sulfur-black-powder", "mam/black-powder", "mam", "mam-sulfur", "m-8-2", 3, {"mam-sulfur-sulfur"}, {
	{"sulfur",50},
	{"coal",25}
}, {
	{type="unlock-recipe",recipe="black-powder"}
})
addTech("mam-sulfur-volatile-applications", "mam/key", "mam", "mam-sulfur", "m-8-3", 3, {"mam-sulfur-black-powder"}, {
	{"black-powder",50}
}, {})
addTech("mam-sulfur-nobelisk-detonator", "mam/nobelisk-detonator", "mam", "mam-sulfur", "m-8-4", 180, {"mam-sulfur-volatile-applications"}, {
	{"encased-industrial-beam",10},
	{"copper-cable",100},
	{"object-scanner",5}
}, {
	-- {type="unlock-recipe",recipe="nobelisk-detonator"}
})
addTech("mam-sulfur-nobelisk", "mam/nobelisk", "mam", "mam-sulfur", "m-8-5", 3, {"mam-sulfur-nobelisk-detonator"}, {
	{"black-powder",100},
	{"steel-pipe",100}
}, {
	-- {type="unlock-recipe",recipe="nobelisk"}
})
addTech("mam-sulfur-rifle", "mam/rifle", "mam", "mam-sulfur", "m-8-6", 180, {"mam-sulfur-volatile-applications"}, {
	{"steel-pipe",100},
	{"electronic-circuit",100},
	{"heavy-modular-frame",5}
}, {
	{type="unlock-recipe",recipe="submachine-gun"}
})
addTech("mam-sulfur-rifle-cartridges", "mam/rifle-cartridge", "mam", "mam-sulfur", "m-8-7", 3, {"mam-sulfur-rifle"}, {
	{"black-powder",200},
	{"steel-pipe",200},
	{"rubber",200}
}, {
	{type="unlock-recipe",recipe="firearm-magazine"}
})
addTech("mam-sulfur-inflated-pocket-dimension", "mam/thumbsup", "mam", "mam-sulfur", "m-8-8", 180, {"mam-sulfur-nobelisk","mam-sulfur-rifle-cartridges"}, {
	{"black-powder",50},
	{"steel-plate",100}
}, {
	{type="character-inventory-slots-bonus",modifier=5}
})
