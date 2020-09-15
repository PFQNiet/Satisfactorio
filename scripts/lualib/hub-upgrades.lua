return {
	-- These are called on research completion to unlock hand-crafting recipes and building-undo recipes
	-- Tier 0 also has some HUB upgrades done here, and also unlocks the next HUB upgrade (or Tier 1/2 for the last one)
	-- This helps avoid polluting the tech effects screen
	-- Table of recipe names, with optional table for extra bits
	-- TODO Update floor graphics according to progression
	["hub-tier0-hub-upgrade-1"] = {
		"hub-tier0-hub-upgrade-2",
		"equipment-workshop-undo",
		{"storage"}
	},
	["hub-tier0-hub-upgrade-2"] = {
		"hub-tier0-hub-upgrade-3",
		"smelter-undo",
		"copper-ingot-manual",
		"wire-manual",
		"copper-cable-manual",
		{"burner1"}
	},
	["hub-tier0-hub-upgrade-3"] = {
		"hub-tier0-hub-upgrade-4",
		"constructor-undo",
		"small-electric-pole-undo",
		"concrete-manual",
		"screw-manual",
		"reinforced-iron-plate-manual"
	},
	["hub-tier0-hub-upgrade-4"] = {
		"hub-tier0-hub-upgrade-5",
		"transport-belt-undo"
	},
	["hub-tier0-hub-upgrade-5"] = {
		"hub-tier0-hub-upgrade-6",
		"miner-mk-1-undo",
		"iron-chest-undo",
		{"burner2"}
	},
	["hub-tier0-hub-upgrade-6"] = {
		"hub-tier1-base-building",
		"hub-tier1-logistics-mk-1",
		"hub-tier1-field-research",
		"hub-tier2-part-assembly",
		"hub-tier2-obstacle-clearing",
		-- "hub-tier2-jump-pads",
		-- "hub-tier2-resource-sink-bonus-program",
		"hub-tier2-logistics-mk-2",
		"space-elevator-phase1",
		"space-elevator-undo",
		"biomass-burner-undo",
		"biomass-from-wood-manual",
		"biomass-from-leaves-manual",
		{"freight"}
	},
	["hub-tier1-base-building"] = {
		"lookout-tower-undo",
		"foundation-undo",
		"stone-wall-undo"
	},
	["hub-tier1-logistics-mk-1"] = {
		"conveyor-splitter-undo",
		"conveyor-merger-undo",
		"underground-belt-undo"
	},
	["hub-tier1-field-research"] = {
		"mam-undo",
		"wooden-chest-undo"
	},
	["hub-tier2-part-assembly"] = {
		"assembler-undo"
	},
	["hub-tier2-obstacle-clearing"] = {
		"solid-biofuel-manual"
	},
	["hub-tier2-jump-pads"] = {
		"jump-pad-undo",
		"u-jelly-landing-pad-undo"
	},
	["hub-tier2-resource-sink-bonus-program"] = {
		"awesome-sink-undo",
		"awesome-shop-undo"
	},
	["hub-tier2-logistics-mk-2"] = {
		"fast-transport-belt-undo",
		"fast-underground-belt-undo"
	},
	["hub-tier3-coal-power"] = {
		"coal-generator-undo",
		"water-extractor-undo",
		"pipe-undo",
		"pipe-to-ground-undo",
		"pump-undo",
		"fluid-buffer-undo"
	},
	["hub-tier3-vehicular-transport"] = {
		"truck-station-undo",
		"tractor-undo"
	},
	["hub-tier3-basic-steel-production"] = {
		"foundry-undo",
		"steel-ingot-manual",
		"steel-plate-manual",
		"steel-pipe-manual"
	}
}
