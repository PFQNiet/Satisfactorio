-- returns the addTech function, which can be used in mod compatibility scripts

-- a special invisible lab that accepts all of the "fake" items used to progress the game
local lab = {
	name = "omnilab",
	type = "lab",
	collision_box = {{-1.3,-1.3},{1.3,1.3}},
	collision_mask = {},
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	off_animation = empty_graphic,
	on_animation = empty_graphic,
	inputs = {},
	researching_speed = 1,
	energy_source = {type="void"},
	energy_usage = "1W",
	flags = {"hidden","hide-alt-info"},
	selectable_in_game = false,
	icon = graphics.."/icons/mam.png",
	icon_size = 64,
	max_health = 1,
	minable = nil
}
data:extend{lab}

data.raw['utility-sprites'].default.character_inventory_slots_bonus_modifier_icon = {
	filename = graphics.."technology/mam/thumbsup.png",
	width = 256,
	height = 256
}

local function addTech(name, icon, category, subgroup, order, time, prerequisites, ingredients, effects, name_override)
	if category == "mam" then
		table.insert(lab.inputs, name)
	end
	local iconsize = 256
	if type(icon) == "table" then
		iconsize = icon.size
		icon = icon.filename
	end
	if icon:sub(1,1) ~= "_" then
		icon = graphics.."technology/"..icon..".png"
	end

	local parts = {
		tool = {
			type = "tool",
			name = name,
			auto_generate_description = effects,
			subgroup = subgroup,
			order = order,
			icons = {{
				icon = icon,
				icon_size = iconsize,
				scale = 64/iconsize
			}},
			stack_size = 1,
			durability = 1,
			flags = {"hidden","only-in-cursor"}
		},
		recipe = {
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
					icon = icon,
					icon_size = iconsize,
					scale = 28/iconsize
				}
			}
		},
		recipe_done = {
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
					icon = icon,
					icon_size = iconsize,
					scale = 28/iconsize
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
		technology = {
			type = "technology",
			name = name,
			localised_name = {"item-name."..name},
			order = order,
			icon = icon,
			icon_size = iconsize,
			prerequisites = prerequisites,
			unit = {
				count = 1,
				time = time,
				ingredients = {{name,1}},
			},
			effects = effects
		}
	}
	if name_override then
		parts.tool.localised_name = name_override
		parts.recipe.localised_name = name_override
		parts.recipe_done.localised_name = name_override
		parts.technology.localised_name = name_override
	end
	data:extend{parts.tool, parts.recipe, parts.recipe_done, parts.technology}
	return parts
end

data:extend{
	{
		type = "technology",
		name = "the-hub",
		order = "a",
		icon = graphics.."technology/hub/the-hub.png",
		icon_size = 256,
		unit = {
			count = 1,
			time = 1,
			ingredients = {{"hub-parts",1}},
		},
		effects = {}
	},
	{
		icon = graphics.."icons/hub-parts.png",
		icon_size = 64,
		name = "hub-parts",
		order = "a[hub-parts]",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	}
}

local parts = addTech("hub-tier0-hub-upgrade1", "hub/hub-upgrade-1-2", "hub-progressing", "hub-tier0", "a-0-1", 1, {"the-hub"}, {
	{"iron-rod",10}
}, {
	{type="unlock-recipe",recipe="equipment-workshop"},
	{type="unlock-recipe",recipe="portable-miner"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false},
	{
		type = "nothing",
		effect_description = {"technology-effect.add-storage-to-hub"},
		icons = {
			{icon = graphics.."icons/the-hub.png", icon_size = 64},
			{icon = graphics.."icons/personal-storage-box.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
		}
	}
})
parts.recipe.enabled = true
addTech("hub-tier0-hub-upgrade2", "hub/hub-upgrade-1-2", "hub-progressing", "hub-tier0", "a-0-2", 1, {"hub-tier0-hub-upgrade1"}, {
	{"iron-rod",20},
	{"iron-plate",10}
}, {
	{type="unlock-recipe",recipe="smelter"},
	{type="unlock-recipe",recipe="copper-ingot"},
	{type="unlock-recipe",recipe="wire"},
	{type="unlock-recipe",recipe="copper-cable"},
	{type="unlock-recipe",recipe="scanner-copper-ore"},
	{
		type = "nothing",
		effect_description = {"technology-effect.add-biomass-burner-to-hub"},
		icons = {
			{icon = graphics.."icons/the-hub.png", icon_size = 64},
			{icon = graphics.."icons/biomass-burner.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
		}
	}
})
addTech("hub-tier0-hub-upgrade3", "hub/hub-upgrade-3", "hub-progressing", "hub-tier0", "a-0-3", 1, {"hub-tier0-hub-upgrade2"}, {
	{"iron-plate",20},
	{"iron-rod",20},
	{"wire",20}
}, {
	{type="unlock-recipe",recipe="constructor"},
	{type="unlock-recipe",recipe="power-pole-mk-1"},
	{type="unlock-recipe",recipe="concrete"},
	{type="unlock-recipe",recipe="screw"},
	{type="unlock-recipe",recipe="reinforced-iron-plate"},
	{type="unlock-recipe",recipe="scanner-stone"}
})
addTech("hub-tier0-hub-upgrade4", "hub/hub-upgrade-4", "hub-progressing", "hub-tier0", "a-0-4", 1, {"hub-tier0-hub-upgrade3"}, {
	{"iron-plate",75},
	{"copper-cable",20},
	{"concrete",10}
}, {
	{type="unlock-recipe",recipe="conveyor-belt-mk-1"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier0-hub-upgrade5", "hub/hub-upgrade-5", "hub-progressing", "hub-tier0", "a-0-5", 1, {"hub-tier0-hub-upgrade4"}, {
	{"iron-rod",75},
	{"copper-cable",50},
	{"concrete",20}
}, {
	{type="unlock-recipe",recipe="miner-mk-1"},
	{type="unlock-recipe",recipe="storage-container"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false},
	{
		type = "nothing",
		effect_description = {"technology-effect.add-biomass-burner-to-hub"},
		icons = {
			{icon = graphics.."icons/the-hub.png", icon_size = 64},
			{icon = graphics.."icons/biomass-burner.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
		}
	}
})
addTech("hub-tier0-hub-upgrade6", "hub/hub-upgrade-6", "hub-progressing", "hub-tier0", "a-0-6", 1, {"hub-tier0-hub-upgrade5"}, {
	{"iron-rod",100},
	{"iron-plate",100},
	{"wire",100},
	{"concrete",50}
}, {
	{type="unlock-recipe",recipe="space-elevator"},
	{type="unlock-recipe",recipe="biomass-burner"},
	{type="unlock-recipe",recipe="biomass-from-leaves"},
	{type="unlock-recipe",recipe="biomass-from-wood"},
	{
		type = "nothing",
		effect_description = {"technology-effect.add-ficsit-freighter-to-hub"},
		icons = {
			{icon = graphics.."icons/the-hub.png", icon_size = 64},
			{icon = graphics.."icons/drop-pod.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
		}
	},
	{type="unlock-recipe",recipe="hub-tier1"},
	{type="unlock-recipe",recipe="hub-tier2"}
})

addTech("hub-tier1-base-building", "hub/structure", "hub-progressing", "hub-tier1", "a-1-1", 120, {"hub-tier0-hub-upgrade6"}, {
	{"concrete",200},
	{"iron-plate",100},
	{"iron-rod",100}
}, {
	{type="unlock-recipe",recipe="lookout-tower"},
	{type="unlock-recipe",recipe="foundation"},
	{type="unlock-recipe",recipe="wall"}
})
addTech("hub-tier1-logistics-mk1", "hub/logistics", "hub-progressing", "hub-tier1", "a-1-2", 240, {"hub-tier0-hub-upgrade6"}, {
	{"iron-plate",150},
	{"iron-rod",150},
	{"wire",300}
}, {
	{type="unlock-recipe",recipe="conveyor-splitter"},
	{type="unlock-recipe",recipe="conveyor-merger"},
	{type="unlock-recipe",recipe="conveyor-lift-mk-1"}
})
addTech("hub-tier1-field-research", "hub/equipment", "hub-progressing", "hub-tier1", "a-1-3", 180, {"hub-tier0-hub-upgrade6"}, {
	{"wire",300},
	{"screw",300},
	{"iron-plate",100}
}, {
	{type="unlock-recipe",recipe="mam"},
	{type="unlock-recipe",recipe="personal-storage-box"},
	{type="unlock-recipe",recipe="map-marker"},
	{type="unlock-recipe",recipe="object-scanner"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})

addTech("hub-tier2-part-assembly", "hub/factory", "hub-progressing", "hub-tier2", "a-2-1", 360, {"hub-tier0-hub-upgrade6"}, {
	{"iron-plate",300},
	{"iron-rod",200},
	{"screw",500},
	{"copper-cable",200}
}, {
	{type="unlock-recipe",recipe="assembler"},
	{type="unlock-recipe",recipe="copper-sheet"},
	{type="unlock-recipe",recipe="rotor"},
	{type="unlock-recipe",recipe="modular-frame"},
	{type="unlock-recipe",recipe="smart-plating"}
})
addTech("hub-tier2-obstacle-clearing", "hub/equipment", "hub-progressing", "hub-tier2", "a-2-2", 180, {"hub-tier0-hub-upgrade6"}, {
	{"screw",500},
	{"copper-cable",100},
	{"concrete",100}
}, {
	{type="unlock-recipe",recipe="solid-biofuel"},
	{type="unlock-recipe",recipe="chainsaw"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier2-jump-pads", "hub/structure", "hub-progressing", "hub-tier2", "a-2-3", 240, {"hub-tier0-hub-upgrade6"}, {
	{"rotor",50},
	{"iron-plate",300},
	{"copper-cable",150}
}, {
	{type="unlock-recipe",recipe="jump-pad"},
	{type="unlock-recipe",recipe="u-jelly-landing-pad"}
})
addTech("hub-tier2-resource-sink-bonus-program", "hub/factory", "hub-progressing", "hub-tier2", "a-2-4", 300, {"hub-tier0-hub-upgrade6"}, {
	{"concrete",400},
	{"wire",500},
	{"iron-rod",200},
	{"iron-plate",200}
}, {
	{type="unlock-recipe",recipe="awesome-sink"},
	{type="unlock-recipe",recipe="awesome-shop"}
})
addTech("hub-tier2-logistics-mk2", "hub/logistics", "hub-progressing", "hub-tier2", "a-2-5", 360, {"hub-tier0-hub-upgrade6"}, {
	{"reinforced-iron-plate",50},
	{"concrete",200},
	{"iron-rod",300},
	{"iron-plate",300}
}, {
	{type="unlock-recipe",recipe="conveyor-belt-mk-2"},
	{type="unlock-recipe",recipe="conveyor-lift-mk-2"}
})

addTech("hub-tier3-coal-power", "hub/factory", "hub-progressing", "hub-tier3", "a-3-1", 480, {"space-elevator-phase1"}, {
	{"reinforced-iron-plate",150},
	{"rotor",50},
	{"copper-cable",300}
}, {
	{type="unlock-recipe",recipe="coal-generator"},
	{type="unlock-recipe",recipe="water-extractor"},
	{type="unlock-recipe",recipe="pipeline"},
	{type="unlock-recipe",recipe="underground-pipeline"},
	{type="unlock-recipe",recipe="pipeline-pump"},
	{type="unlock-recipe",recipe="fluid-buffer"},
	{type="unlock-recipe",recipe="scanner-coal"}
})
addTech("hub-tier3-vehicular-transport", "hub/vehicle", "hub-progressing", "hub-tier3", "a-3-2", 240, {"space-elevator-phase1"}, {
	{"modular-frame",25},
	{"rotor",100},
	{"copper-cable",200},
	{"iron-rod",400}
}, {
	{type="unlock-recipe",recipe="truck-station"},
	{type="unlock-recipe",recipe="tractor"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier3-basic-steel-production", "hub/factory", "hub-progressing", "hub-tier3", "a-3-3", 480, {"space-elevator-phase1"}, {
	{"modular-frame",50},
	{"rotor",150},
	{"concrete",300},
	{"wire",1000}
}, {
	{type="unlock-recipe",recipe="foundry"},
	{type="unlock-recipe",recipe="steel-ingot"},
	{type="unlock-recipe",recipe="steel-beam"},
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
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier4-hyper-tubes", "hub/structure", "hub-progressing", "hub-tier4", "a-4-3", 600, {"space-elevator-phase1"}, {
	{"copper-sheet",300},
	{"steel-pipe",300},
	{"encased-industrial-beam",50}
}, {
	{type="unlock-recipe",recipe="hyper-tube-entrance"},
	{type="unlock-recipe",recipe="hyper-tube"},
	{type="unlock-recipe",recipe="underground-hyper-tube"}
})
addTech("hub-tier4-logistics-mk3", "hub/logistics", "hub-progressing", "hub-tier4", "a-4-4", 300, {"space-elevator-phase1"}, {
	{"steel-beam",200},
	{"steel-pipe",100},
	{"concrete",500}
}, {
	{type="unlock-recipe",recipe="power-storage"},
	{type="unlock-recipe",recipe="industrial-storage-container"},
	{type="unlock-recipe",recipe="conveyor-belt-mk-3"},
	{type="unlock-recipe",recipe="conveyor-lift-mk-3"}
})

addTech("hub-tier5-oil-processing", "hub/factory", "hub-progressing", "hub-tier5", "a-5-1", 720, {"space-elevator-phase2"}, {
	{"motor",50},
	{"encased-industrial-beam",100},
	{"steel-pipe",500},
	{"copper-sheet",500}
}, {
	{type="unlock-recipe",recipe="oil-extractor"},
	{type="unlock-recipe",recipe="refinery"},
	{type="unlock-recipe",recipe="valve"},
	{type="unlock-recipe",recipe="plastic"},
	{type="unlock-recipe",recipe="residual-plastic"},
	{type="unlock-recipe",recipe="rubber"},
	{type="unlock-recipe",recipe="residual-rubber"},
	{type="unlock-recipe",recipe="fuel"},
	{type="unlock-recipe",recipe="residual-fuel"},
	{type="unlock-recipe",recipe="petroleum-coke"},
	{type="unlock-recipe",recipe="circuit-board"},
	{type="unlock-recipe",recipe="scanner-crude-oil"}
})
addTech("hub-tier5-industrial-manufacturing", "hub/factory", "hub-progressing", "hub-tier5", "a-5-2", 720, {"space-elevator-phase2"}, {
	{"motor",100},
	{"plastic",200},
	{"rubber",200},
	{"copper-cable",1000}
}, {
	{type="unlock-recipe",recipe="manufacturer"},
	{type="unlock-recipe",recipe="truck"},
	{type="unlock-recipe",recipe="computer"},
	{type="unlock-recipe",recipe="modular-engine"},
	{type="unlock-recipe",recipe="adaptive-control-unit"}
})
addTech("hub-tier5-gas-mask", "hub/equipment", "hub-progressing", "hub-tier5", "a-5-3", 300, {"space-elevator-phase2"}, {
	{"rubber",200},
	{"plastic",100},
	{"fabric",50}
}, {
	{type="unlock-recipe",recipe="gas-mask"},
	{type="unlock-recipe",recipe="gas-filter"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier5-alternative-fluid-transport", "hub/logistics", "hub-progressing", "hub-tier5", "a-5-4", 480, {"space-elevator-phase2"}, {
	{"heavy-modular-frame",25},
	{"motor",100},
	{"plastic",200},
	{"wire",3000}
}, {
	{type="unlock-recipe",recipe="industrial-fluid-buffer"},
	{type="unlock-recipe",recipe="packager"},
	{type="unlock-recipe",recipe="empty-canister"},
	{type="unlock-recipe",recipe="packaged-water"},
	{type="unlock-recipe",recipe="unpack-water"},
	{type="unlock-recipe",recipe="packaged-oil"},
	{type="unlock-recipe",recipe="unpack-oil"},
	{type="unlock-recipe",recipe="packaged-heavy-oil-residue"},
	{type="unlock-recipe",recipe="unpack-heavy-oil-residue"},
	{type="unlock-recipe",recipe="packaged-fuel"},
	{type="unlock-recipe",recipe="unpack-fuel"},
	{type="unlock-recipe",recipe="packaged-liquid-biofuel"},
	{type="unlock-recipe",recipe="unpack-liquid-biofuel"},
	{type="unlock-recipe",recipe="liquid-biofuel"}
})

addTech("hub-tier6-expanded-power-infrastructure", "hub/logistics", "hub-progressing", "hub-tier6", "a-6-1", 900, {"space-elevator-phase2"}, {
	{"heavy-modular-frame",50},
	{"computer",100},
	{"encased-industrial-beam",200},
	{"rubber",400}
}, {
	{type="unlock-recipe",recipe="fuel-generator"},
	{type="unlock-recipe",recipe="conveyor-belt-mk-4"},
	{type="unlock-recipe",recipe="conveyor-lift-mk-4"},
	{type="unlock-recipe",recipe="scanner-caterium-ore"}
})
addTech("hub-tier6-jetpack", "hub/equipment", "hub-progressing", "hub-tier6", "a-6-2", 300, {"space-elevator-phase2"}, {
	{"packaged-fuel",50},
	{"motor",50},
	{"plastic",100},
	{"rubber",100}
}, {
	{type="unlock-recipe",recipe="jetpack"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier6-monorail-train-technology", "hub/vehicle", "hub-progressing", "hub-tier6", "a-6-3", 900, {"space-elevator-phase2"}, {
	{"computer",50},
	{"heavy-modular-frame",100},
	{"steel-beam",500},
	{"steel-pipe",600}
}, {
	{type="unlock-recipe",recipe="rail"},
	{type="unlock-recipe",recipe="rail-signal"},
	{type="unlock-recipe",recipe="rail-chain-signal"},
	{type="unlock-recipe",recipe="train-station"},
	{type="unlock-recipe",recipe="freight-platform"},
	{type="unlock-recipe",recipe="fluid-freight-platform"},
	{type="unlock-recipe",recipe="empty-platform"},
	{type="unlock-recipe",recipe="locomotive"},
	{type="unlock-recipe",recipe="cargo-wagon"},
	{type="unlock-recipe",recipe="fluid-wagon"}
})
addTech("hub-tier6-pipeline-engineering-mk2", "hub/logistics", "hub-progressing", "hub-tier6", "a-6-4", 600, {"space-elevator-phase2"}, {
	{"copper-sheet",1000},
	{"plastic",400},
	{"rubber",400},
	{"heavy-modular-frame",50}
}, {
	{type="unlock-recipe",recipe="pipeline-mk-2"},
	{type="unlock-recipe",recipe="underground-pipeline-mk-2"},
	{type="unlock-recipe",recipe="pipeline-pump-mk-2"}
})

addTech("hub-tier7-bauxite-refinement", "hub/factory", "hub-progressing", "hub-tier7", "a-7-1", 900, {"space-elevator-phase3"}, {
	{"motor",200},
	{"computer",100},
	{"heavy-modular-frame",100}
}, {
	{type="unlock-recipe",recipe="blender"},
	{type="unlock-recipe",recipe="alumina-solution"},
	{type="unlock-recipe",recipe="aluminium-scrap"},
	{type="unlock-recipe",recipe="aluminium-ingot"},
	{type="unlock-recipe",recipe="alclad-aluminium-sheet"},
	{type="unlock-recipe",recipe="aluminium-casing"},
	{type="unlock-recipe",recipe="radio-control-unit"},
	{type="unlock-recipe",recipe="packaged-alumina-solution"},
	{type="unlock-recipe",recipe="unpack-alumina-solution"},
	{type="unlock-recipe",recipe="scanner-bauxite"},
	{type="unlock-recipe",recipe="scanner-raw-quartz"}
})
addTech("hub-tier7-logistics-mk5", "hub/logistics", "hub-progressing", "hub-tier7", "a-7-2", 60, {"space-elevator-phase3"}, {
	{"alclad-aluminium-sheet",100},
	{"encased-industrial-beam",500},
	{"reinforced-iron-plate",300}
}, {
	{type="unlock-recipe",recipe="conveyor-belt-mk-5"},
	{type="unlock-recipe",recipe="conveyor-lift-mk-5"}
})
addTech("hub-tier7-aeronautical-engineering", "hub/vehicle", "hub-progressing", "hub-tier7", "a-7-3", 600, {"space-elevator-phase3"}, {
	{"radio-control-unit",50},
	{"alclad-aluminium-sheet",100},
	{"aluminium-casing",200},
	{"motor",300}
}, {
	{type="unlock-recipe",recipe="drone-port"},
	{type="unlock-recipe",recipe="drone"},
	{type="unlock-recipe",recipe="sulfuric-acid"},
	{type="unlock-recipe",recipe="battery"},
	{type="unlock-recipe",recipe="supercomputer"},
	{type="unlock-recipe",recipe="assembly-director-system"},
	{type="unlock-recipe",recipe="packaged-sulfuric-acid"},
	{type="unlock-recipe",recipe="unpack-sulfuric-acid"},
	{type="unlock-recipe",recipe="scanner-sulfur"}
})
addTech("hub-tier7-hazmat-suit", "hub/equipment", "hub-progressing", "hub-tier7", "a-7-4", 300, {"space-elevator-phase3"}, {
	{"aluminium-casing",50},
	{"quickwire",500},
	{"gas-filter",50}
}, {
	{type="unlock-recipe",recipe="hazmat-suit"},
	{type="unlock-recipe",recipe="iodine-infused-filter"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier7-hover-pack", "hub/equipment", "hub-progressing", "hub-tier7", "a-7-5", 300, {"space-elevator-phase3"}, {
	{"motor",200},
	{"heavy-modular-frame",100},
	{"computer",100},
	{"alclad-aluminium-sheet",200}
}, {
	{type="unlock-recipe",recipe="hover-pack"},
	{type="character-inventory-slots-bonus",modifier=3,use_icon_overlay_constant=false}
})
addTech("hub-tier8-nuclear-power", "hub/factory", "hub-progressing", "hub-tier8", "a-8-1", 600, {"space-elevator-phase3"}, {
	{"supercomputer",50},
	{"heavy-modular-frame",200},
	{"copper-cable",1000},
	{"concrete",2000}
}, {
	{type="unlock-recipe",recipe="nuclear-power-plant"},
	{type="unlock-recipe",recipe="encased-uranium-cell"},
	{type="unlock-recipe",recipe="electromagnetic-control-rod"},
	{type="unlock-recipe",recipe="uranium-fuel-rod"},
	{type="unlock-recipe",recipe="magnetic-field-generator"},
	{type="unlock-recipe",recipe="scanner-uranium-ore"}
})
addTech("hub-tier8-advanced-aluminium-production", "hub/factory", "hub-progressing", "hub-tier8", "a-8-2", 900, {"space-elevator-phase3"}, {
	{"radio-control-unit",50},
	{"aluminium-casing",100},
	{"alclad-aluminium-sheet",200},
	{"wire",3000}
}, {
	{type="unlock-recipe",recipe="resource-well-pressuriser"},
	{type="unlock-recipe",recipe="resource-well-extractor"},
	{type="unlock-recipe",recipe="empty-fluid-tank"},
	{type="unlock-recipe",recipe="packaged-nitrogen-gas"},
	{type="unlock-recipe",recipe="unpack-nitrogen-gas"},
	{type="unlock-recipe",recipe="heat-sink"},
	{type="unlock-recipe",recipe="cooling-system"},
	{type="unlock-recipe",recipe="fused-modular-frame"},
	{type="unlock-recipe",recipe="scanner-water"},
	{type="unlock-recipe",recipe="scanner-nitrogen-gas"}
})
addTech("hub-tier8-leading-edge-production", "hub/factory", "hub-progressing", "hub-tier8", "a-8-3", 300, {"space-elevator-phase3"}, {
	{"fused-modular-frame",50},
	{"supercomputer",100},
	{"steel-pipe",1000}
}, {
	{type="unlock-recipe",recipe="miner-mk-3"},
	{type="unlock-recipe",recipe="turbo-motor"},
	{type="unlock-recipe",recipe="thermal-propulsion-rocket"}
})
addTech("hub-tier8-particle-enrichment", "hub/factory", "hub-progressing", "hub-tier8", "a-8-4", 1200, {"space-elevator-phase3"}, {
	{"electromagnetic-control-rod",400},
	{"cooling-system",400},
	{"fused-modular-frame",200},
	{"turbo-motor",100}
}, {
	{type="unlock-recipe",recipe="particle-accelerator"},
	{type="unlock-recipe",recipe="nitric-acid"},
	{type="unlock-recipe",recipe="non-fissile-uranium"},
	{type="unlock-recipe",recipe="plutonium-pellet"},
	{type="unlock-recipe",recipe="encased-plutonium-cell"},
	{type="unlock-recipe",recipe="plutonium-fuel-rod"},
	{type="unlock-recipe",recipe="copper-powder"},
	{type="unlock-recipe",recipe="pressure-conversion-cube"},
	{type="unlock-recipe",recipe="nuclear-pasta"},
	{type="unlock-recipe",recipe="packaged-nitric-acid"},
	{type="unlock-recipe",recipe="unpack-nitric-acid"}
})

--[[ SPACE ELEVATOR ]]--
addTech("space-elevator-phase1", "space/smart-plating", "space-elevator", "space-elevator-phases", "e-1", 1, {"hub-tier0-hub-upgrade6"}, {
	{"smart-plating",50}
}, {
	{type="unlock-recipe",recipe="hub-tier3"},
	{type="unlock-recipe",recipe="hub-tier4"}
})
addTech("space-elevator-phase2", "space/versatile-framework", "space-elevator", "space-elevator-phases", "e-2", 1, {"space-elevator-phase1"}, {
	{"smart-plating",500},
	{"versatile-framework",500},
	{"automated-wiring",100}
}, {
	{type="unlock-recipe",recipe="hub-tier5"},
	{type="unlock-recipe",recipe="hub-tier6"}
})
addTech("space-elevator-phase3", "space/adaptive-control-unit", "space-elevator", "space-elevator-phases", "e-3", 1, {"space-elevator-phase2"}, {
	{"versatile-framework",2500},
	{"modular-engine",500},
	{"adaptive-control-unit",100}
}, {
	{type="unlock-recipe",recipe="hub-tier7"},
	{type="unlock-recipe",recipe="hub-tier8"}
})
addTech("space-elevator-phase4", "space/assembly-director-system", "space-elevator", "space-elevator-phases", "e-4", 1, {"space-elevator-phase3"}, {
	{"assembly-director-system",4000},
	{"magnetic-field-generator",4000},
	{"thermal-propulsion-rocket",1000},
	{"nuclear-pasta",1000}
}, {
	{
		type = "nothing",
		effect_description = {"technology-effect.win-the-game"},
		icons = {
			{icon = graphics.."icons/satisfactory-pioneering.png", icon_size = 64}
		}
	}
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
	{type="unlock-recipe",recipe="rebar-gun"}
})
addTech("mam-alien-organisms-spiked-rebars", "mam/spiked-rebar", "mam", "mam-alien-organisms", "m-1-7", 3, {"mam-alien-organisms-rebar-gun"}, {
	{"rotor",25},
	{"iron-rod",200}
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
	{type="unlock-recipe",recipe="scanner-enemies"}
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
	{type="character-inventory-slots-bonus",modifier=6,use_icon_overlay_constant=false}
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
addTech("mam-caterium-inflated-pocket-dimension", "mam/thumbsup", "mam", "mam-caterium", "m-2-4", 120, {"mam-caterium-caterium-ingots"}, {
	{"caterium-ingot",10},
	{"wire",500},
	{"reinforced-iron-plate",50}
}, {
	{type="character-inventory-slots-bonus",modifier=6,use_icon_overlay_constant=false}
})
addTech("mam-caterium-zipline", "mam/zipline", "mam", "mam-caterium", "m-2-5", 300, {"mam-caterium-caterium-electronics"}, {
	{"quickwire",100},
	{"copper-cable",50}
}, {
	{type="unlock-recipe",recipe="zipline"}
})
addTech("mam-caterium-caterium-electronics", "mam/key", "mam", "mam-caterium", "m-2-6", 3, {"mam-caterium-quickwire"}, {
	{"quickwire",100}
}, {})
addTech("mam-caterium-blade-runners", "mam/blade-runners", "mam", "mam-caterium", "m-2-7", 300, {"mam-caterium-caterium-electronics"}, {
	{"quickwire",100},
	{"modular-frame",10}
}, {
	{type="unlock-recipe",recipe="blade-runners"}
})
addTech("mam-caterium-ai-limiter", "mam/ai-limiter", "mam", "mam-caterium", "m-2-8", 3, {"mam-caterium-caterium-electronics"}, {
	{"quickwire",200},
	{"copper-sheet",50}
}, {
	{type="unlock-recipe",recipe="ai-limiter"}
})
addTech("mam-caterium-power-poles-mk2", "mam/power-pole-mk2", "mam", "mam-caterium", "m-2-9", 300, {"mam-caterium-caterium-electronics"}, {
	{"quickwire",300}
}, {
	{type="unlock-recipe",recipe="power-pole-mk-2"}
})
addTech("mam-caterium-smart-splitter", "mam/smart-splitter", "mam", "mam-caterium", "m-2-a", 300, {"mam-caterium-ai-limiter"}, {
	{"ai-limiter",10},
	{"reinforced-iron-plate",50}
}, {
	{type="unlock-recipe",recipe="smart-splitter"}
})
addTech("mam-caterium-power-switch", "mam/power-switch", "mam", "mam-caterium", "m-2-b", 300, {"mam-caterium-ai-limiter"}, {
	{"steel-beam",100},
	{"ai-limiter",50}
}, {
	{type="unlock-recipe",recipe="power-switch"}
})
addTech("mam-caterium-high-speed-connector", "mam/high-speed-connector", "mam", "mam-caterium", "m-2-c", 3, {"mam-caterium-ai-limiter"}, {
	{"quickwire",500},
	{"plastic",50}
}, {
	{type="unlock-recipe",recipe="high-speed-connector"}
})
addTech("mam-caterium-supercomputer", "mam/supercomputer", "mam", "mam-caterium", "m-2-d", 3, {"mam-caterium-high-speed-connector"}, {
	{"ai-limiter",50},
	{"high-speed-connector",50},
	{"computer",50}
}, {
	{type="unlock-recipe",recipe="supercomputer"}
})
addTech("mam-caterium-power-poles-mk3", "mam/power-pole-mk3", "mam", "mam-caterium", "m-2-e", 360, {"mam-caterium-high-speed-connector"}, {
	{"high-speed-connector",100},
	{"steel-pipe",200}
}, {
	{type="unlock-recipe",recipe="power-pole-mk-3"}
})
addTech("mam-caterium-programmable-splitter", "mam/programmable-splitter", "mam", "mam-caterium", "m-2-f", 480, {"mam-caterium-supercomputer"}, {
	{"supercomputer",50},
	{"heavy-modular-frame",50}
}, {
	{type="unlock-recipe",recipe="programmable-splitter"}
})
addTech("mam-caterium-geothermal-generator", "mam/geothermal-generator", "mam", "mam-caterium", "m-2-g", 480, {"mam-caterium-supercomputer"}, {
	{"supercomputer",50},
	{"heavy-modular-frame",50},
	{"rubber",300}
}, {
	{type="unlock-recipe",recipe="geothermal-generator"},
	{type="unlock-recipe",recipe="scanner-geyser"}
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
addTech("mam-mycelia-parachute", "mam/parachute", "mam", "mam-mycelia", "m-4-5", 3, {"mam-mycelia-fabric"}, {
	{"fabric",10},
	{"copper-cable",50}
}, {
	{type="unlock-recipe",recipe="parachute"}
})

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
	{"iron-rod",50},
	{"iron-plate",50},
	{"wire",50}
}, {})
addTech("mam-power-slugs-green-power-slugs", "mam/green-power-slug", "mam", "mam-power-slugs", "m-6-2", 3, {"mam-power-slugs-overclocking"}, {
	{"green-power-slug",1}
}, {
	{type="unlock-recipe",recipe="power-shard-from-green-power-slug"}
})
addTech("mam-power-slugs-slug-scanning", "mam/green-power-slug", "mam", "mam-power-slugs", "m-6-3", 3, {"mam-power-slugs-green-power-slugs"}, {
	{"iron-rod",50},
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
addTech("mam-quartz-factory-lighting", "mam/lights", "mam", "mam-quartz", "m-7-4", 180, {"mam-quartz-quartz-crystals"}, {
	{"quartz-crystal",100},
	{"steel-beam",50}
}, {
	{type="unlock-recipe",recipe="small-lamp"}
})
addTech("mam-quartz-crystal-oscillator", "mam/crystal-oscillator", "mam", "mam-quartz", "m-7-5", 3, {"mam-quartz-quartz-crystals"}, {
	{"quartz-crystal",100},
	{"reinforced-iron-plate",50}
}, {
	{type="unlock-recipe",recipe="crystal-oscillator"}
})
addTech("mam-quartz-signal-technologies", "mam/key", "mam", "mam-quartz", "m-7-6", 3, {"mam-quartz-crystal-oscillator"}, {
	{"crystal-oscillator",5}
}, {})
addTech("mam-quartz-explorer", "mam/explorer", "mam", "mam-quartz", "m-7-7", 300, {"mam-quartz-signal-technologies"}, {
	{"crystal-oscillator",10},
	{"modular-frame",100}
}, {
	{type="unlock-recipe",recipe="explorer"}
})
addTech("mam-quartz-frequency-mapping", "mam/map", "mam", "mam-quartz", "m-7-8", 300, {"mam-quartz-signal-technologies"}, {
	{"crystal-oscillator",10},
	{"map-marker",10}
}, {
	{
		type = "nothing",
		effect_description = {"technology-effect.map"},
		icons = {
			{icon = graphics.."technology/mam/map.png", icon_size = 256}
		}
	}
})
addTech("mam-quartz-radio-signal-scanning", "mam/crash-site", "mam", "mam-quartz", "m-7-9", 300, {"mam-quartz-frequency-mapping"}, {
	{"crystal-oscillator",50},
	{"motor",100},
	{"map-marker",10}
}, {
	{type="unlock-recipe",recipe="scanner-crash-site"}
})
addTech("mam-quartz-radar-technology", "mam/radar-tower", "mam", "mam-quartz", "m-7-a", 3, {"mam-quartz-frequency-mapping"}, {
	{"crystal-oscillator",100},
	{"heavy-modular-frame",50},
	{"map-marker",15}
}, {
	{type="unlock-recipe",recipe="radar-tower"}
})
addTech("mam-quartz-radio-control-unit", "mam/radio-control-unit", "mam", "mam-quartz", "m-7-b", 3, {"mam-quartz-signal-technologies"}, {
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
	{type="unlock-recipe",recipe="nobelisk-detonator"}
})
addTech("mam-sulfur-nobelisk", "mam/nobelisk", "mam", "mam-sulfur", "m-8-5", 3, {"mam-sulfur-nobelisk-detonator"}, {
	{"black-powder",100},
	{"steel-pipe",100}
}, {
	{type="unlock-recipe",recipe="nobelisk"}
})
addTech("mam-sulfur-rifle", "mam/rifle", "mam", "mam-sulfur", "m-8-6", 180, {"mam-sulfur-volatile-applications"}, {
	{"steel-pipe",100},
	{"circuit-board",100},
	{"heavy-modular-frame",5}
}, {
	{type="unlock-recipe",recipe="rifle"}
})
addTech("mam-sulfur-rifle-cartridges", "mam/rifle-cartridge", "mam", "mam-sulfur", "m-8-7", 3, {"mam-sulfur-rifle"}, {
	{"black-powder",200},
	{"steel-pipe",200},
	{"rubber",200}
}, {
	{type="unlock-recipe",recipe="rifle-cartridge"}
})
addTech("mam-sulfur-inflated-pocket-dimension", "mam/thumbsup", "mam", "mam-sulfur", "m-8-8", 180, {"mam-sulfur-nobelisk","mam-sulfur-rifle-cartridges"}, {
	{"black-powder",50},
	{"steel-beam",100}
}, {
	{type="character-inventory-slots-bonus",modifier=6,use_icon_overlay_constant=false}
})

--[[ ALT RECIPES ]]--
local alt_recipe_tech = addTech("mam-hard-drive", "mam/hard-drive", "mam", "mam-hard-drive", "m-0", 600, {"hub-tier1-field-research"}, {
	{"hard-drive",1}
}, {
	{
		type = "nothing",
		effect_description = {"technology-effect.alt-recipe"},
		icons = {
			{icon = graphics.."icons/hard-drive.png", icon_size = 64}
		}
	}
})
alt_recipe_tech.technology.max_level = "infinite"

return addTech
