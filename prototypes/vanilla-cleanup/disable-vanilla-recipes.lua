local vanilla_recipes = { -- items with the same name in Satisfactory are overwritten and should not be removed
	"accumulator",
	"advanced-circuit",
	"advanced-oil-processing",
	"arithmetic-combinator",
	"artillery-shell",
	"artillery-targeting-remote",
	"artillery-turret",
	"artillery-wagon",
	"assembling-machine-1",
	"assembling-machine-2",
	"assembling-machine-3",
	"atomic-bomb",
	"automation-science-pack",
	"basic-oil-processing",
	-- "battery",
	"battery-equipment",
	"battery-mk2-equipment",
	"beacon",
	"belt-immunity-equipment",
	"big-electric-pole",
	"boiler",
	"burner-inserter",
	"burner-mining-drill",
	"cannon-shell",
	"car",
	-- "cargo-wagon",
	"centrifuge",
	"chemical-plant",
	"chemical-science-pack",
	"cliff-explosives",
	"cluster-grenade",
	"coal-liquefaction",
	"combat-shotgun",
	-- "concrete",
	"constant-combinator",
	"construction-robot",
	-- "copper-cable",
	"copper-plate",
	"decider-combinator",
	"defender-capsule",
	"destroyer-capsule",
	"discharge-defense-equipment",
	"discharge-defense-remote",
	"distractor-capsule",
	"effectivity-module",
	"effectivity-module-2",
	"effectivity-module-3",
	"electric-energy-interface",
	"electric-engine-unit",
	"electric-furnace",
	"electric-mining-drill",
	"electronic-circuit",
	"empty-barrel",
	"energy-shield-equipment",
	"energy-shield-mk2-equipment",
	"engine-unit",
	"exoskeleton-equipment",
	"explosive-cannon-shell",
	"explosive-rocket",
	"explosive-uranium-cannon-shell",
	"explosives",
	"express-loader",
	"express-splitter",
	"express-transport-belt",
	"express-underground-belt",
	"fast-inserter",
	"fast-loader",
	"fast-splitter",
	"fast-transport-belt",
	"fast-underground-belt",
	"filter-inserter",
	"firearm-magazine",
	"flamethrower",
	"flamethrower-ammo",
	"flamethrower-turret",
	-- "fluid-wagon",
	"flying-robot-frame",
	"fusion-reactor-equipment",
	"gate",
	"green-wire",
	"grenade",
	"gun-turret",
	"hazard-concrete",
	"heat-exchanger",
	"heat-pipe",
	"heavy-armor",
	"heavy-oil-cracking",
	"inserter",
	"iron-chest",
	"iron-gear-wheel",
	-- "iron-plate",
	"iron-stick",
	"kovarex-enrichment-process",
	"lab",
	"land-mine",
	"landfill",
	"laser-turret",
	"light-armor",
	"light-oil-cracking",
	"loader",
	-- "locomotive",
	"logistic-chest-active-provider",
	"logistic-chest-buffer",
	"logistic-chest-passive-provider",
	"logistic-chest-requester",
	"logistic-chest-storage",
	"logistic-robot",
	"logistic-science-pack",
	"long-handed-inserter",
	"low-density-structure",
	"lubricant",
	"medium-electric-pole",
	"military-science-pack",
	"modular-armor",
	"night-vision-equipment",
	"nuclear-fuel",
	"nuclear-fuel-reprocessing",
	"nuclear-reactor",
	"offshore-pump",
	"oil-refinery",
	"personal-laser-defense-equipment",
	"personal-roboport-equipment",
	"personal-roboport-mk2-equipment",
	"piercing-rounds-magazine",
	"piercing-shotgun-shell",
	"pipe",
	"pipe-to-ground",
	"pistol",
	"plastic-bar",
	"poison-capsule",
	"power-armor",
	"power-armor-mk2",
	-- "power-switch",
	"processing-unit",
	"production-science-pack",
	"productivity-module",
	"productivity-module-2",
	"productivity-module-3",
	"programmable-speaker",
	"pump",
	"pumpjack",
	"radar",
	-- "rail",
	-- "rail-chain-signal",
	-- "rail-signal",
	"red-wire",
	"refined-concrete",
	"refined-hazard-concrete",
	"repair-pack",
	"roboport",
	"rocket",
	"rocket-control-unit",
	"rocket-fuel",
	"rocket-launcher",
	-- "rocket-part", -- Helmod breaks if this recipe is removed. TODO remove it again when Helmod is patched.
	"rocket-silo",
	"satellite",
	"shotgun",
	"shotgun-shell",
	"slowdown-capsule",
	"small-electric-pole",
	-- "small-lamp",
	"solar-panel",
	"solar-panel-equipment",
	"solid-fuel-from-heavy-oil",
	"solid-fuel-from-light-oil",
	"solid-fuel-from-petroleum-gas",
	"speed-module",
	"speed-module-2",
	"speed-module-3",
	"spidertron",
	"spidertron-remote",
	"splitter",
	"stack-filter-inserter",
	"stack-inserter",
	"steam-engine",
	"steam-turbine",
	"steel-chest",
	"steel-furnace",
	"steel-plate",
	"stone-brick",
	"stone-furnace",
	"stone-wall",
	"storage-tank",
	"submachine-gun",
	"substation",
	"sulfur",
	-- "sulfuric-acid",
	"tank",
	"train-stop",
	"transport-belt",
	"underground-belt",
	"uranium-cannon-shell",
	"uranium-fuel-cell",
	"uranium-processing",
	"uranium-rounds-magazine",
	"utility-science-pack",
	"wooden-chest"
}
for _,key in ipairs(vanilla_recipes) do
	data.raw.recipe[key] = nil
end
data.raw["rocket-silo"]["rocket-silo"].fixed_recipe = nil
-- productivity modules are limited to fixed recipes, just nuke that
data.raw.module["productivity-module"].limitation = {}
data.raw.module["productivity-module-2"].limitation = {}
data.raw.module["productivity-module-3"].limitation = {}

data:extend{
	{type="item-group",name="vanilla",order="zzz",icon="__core__/graphics/factorio.png",icon_size=128},
	{type="item-subgroup",group="vanilla",name="vanilla"}
}
local vanilla_items = {
	ammo = {
		"artillery-shell", "atomic-bomb", "cannon-shell", "explosive-cannon-shell", "explosive-rocket", "explosive-uranium-cannon-shell", "firearm-magazine", "flamethrower-ammo", "piercing-rounds-magazine", "piercing-shotgun-shell", "rocket", "shotgun-shell", "uranium-cannon-shell", "uranium-rounds-magazine"
	},
	armor = {
		"heavy-armor", "light-armor", "modular-armor", "power-armor", "power-armor-mk2"
	},
	capsule = {
		"artillery-targeting-remote", "cliff-explosives", "cluster-grenade", "defender-capsule", "destroyer-capsule", "discharge-defense-remote", "distractor-capsule", "grenade", "poison-capsule", "raw-fish", "slowdown-capsule"
	},
	gun = {
		"artillery-wagon-cannon", "combat-shotgun", "flamethrower", "pistol", "rocket-launcher", "shotgun", "spidertron-rocket-launcher-1", "spidertron-rocket-launcher-2", "spidertron-rocket-launcher-3", "spidertron-rocket-launcher-4", "submachine-gun", "tank-cannon", "tank-flamethrower", "tank-machine-gun", "vehicle-machine-gun"
	},
	item = {
		"accumulator", "advanced-circuit", "arithmetic-combinator", "artillery-turret", "assembling-machine-1", "assembling-machine-2", "assembling-machine-3", "battery-equipment", "battery-mk2-equipment", "beacon", "belt-immunity-equipment", "big-electric-pole", "boiler", "burner-generator", "burner-inserter", "burner-mining-drill", "centrifuge", "chemical-plant", "constant-combinator", "construction-robot", "copper-plate", "decider-combinator", "discharge-defense-equipment", "electric-engine-unit", "electric-furnace", "electric-mining-drill", "electronic-circuit", "empty-barrel", "energy-shield-equipment", "energy-shield-mk2-equipment", "engine-unit", "exoskeleton-equipment", "explosives", "express-loader", "express-splitter", "express-transport-belt", "express-underground-belt", "fast-inserter", "fast-loader", "fast-splitter", "fast-transport-belt", "fast-underground-belt", "filter-inserter", "flamethrower-turret", "flying-robot-frame", "fusion-reactor-equipment", "gate", "green-wire", "gun-turret", "hazard-concrete", "heat-exchanger", "heat-interface", "heat-pipe", "infinity-chest", "inserter", "iron-chest", "iron-gear-wheel", "iron-stick", "lab", "land-mine", "landfill", "laser-turret", "linked-belt", "linked-chest", "loader", "logistic-chest-active-provider", "logistic-chest-buffer", "logistic-chest-passive-provider", "logistic-chest-requester", "logistic-chest-storage", "logistic-robot", "long-handed-inserter", "low-density-structure", "medium-electric-pole", "night-vision-equipment", "nuclear-fuel", "nuclear-reactor", "offshore-pump", "oil-refinery", "personal-laser-defense-equipment", "personal-roboport-equipment", "personal-roboport-mk2-equipment", "pipe", "pipe-to-ground", "plastic-bar", "player-port", "processing-unit", "programmable-speaker", "pump", "pumpjack", "radar", "red-wire", "refined-concrete", "refined-hazard-concrete", "roboport", "rocket-control-unit", "rocket-fuel", "rocket-part", "rocket-silo", "satellite", "simple-entity-with-force", "simple-entity-with-owner", "small-electric-pole", "solar-panel", "solar-panel-equipment", "solid-fuel", "splitter", "stack-filter-inserter", "stack-inserter", "steam-engine", "steam-turbine", "steel-chest", "steel-furnace", "steel-plate", "stone-brick", "stone-furnace", "stone-wall", "storage-tank", "substation", "train-stop", "transport-belt", "underground-belt", "uranium-235", "uranium-238", "uranium-fuel-cell", "used-up-uranium-fuel-cell", "wooden-chest"
		-- KEEP
		-- "battery", "coal", "coin", "concrete", "copper-cable", "copper-ore", "electric-energy-interface", "infinity-pipe", "iron-ore", "iron-plate", "item-unknown", "power-switch", "rail-chain-signal", "rail-signal", "small-lamp", "stone", "sulfur", "uranium-ore", "wood"
	},
	["item-with-entity-data"] = {
		"artillery-wagon", "car", "spidertron", "tank"
		-- KEEP
		-- "cargo-wagon", "fluid-wagon", "locomotive"
	},
	["item-with-inventory"] = {"item-with-inventory"},
	["item-with-label"] = {"item-with-label"},
	["item-with-tags"] = {"item-with-tags"},
	module = {
		"effectivity-module", "effectivity-module-2", "effectivity-module-3", "productivity-module", "productivity-module-2", "productivity-module-3", "speed-module", "speed-module-2", "speed-module-3"
	},
	["repair-tool"] = {
		"repair-pack"
	},
	["selection-tool"] = {
		"selection-tool"
	},
	["spidertron-remote"] = {
		"spidertron-remote"
	},
	tool = {
		"automation-science-pack", "chemical-science-pack", "logistic-science-pack", "military-science-pack", "production-science-pack", "space-science-pack", "utility-science-pack"
	}
}
for type,items in pairs(vanilla_items) do
	for _,name in pairs(items) do
		local item = data.raw[type][name]
		assert(item, "Item "..type.."."..name.." not found, check for typo")
		item.subgroup = "vanilla"
		if not item.flags then item.flags = {} end
		table.insert(item.flags, "hidden")
	end
end

local vanilla_fuels = {
	"solid-fuel", "rocket-fuel", "nuclear-fuel", "uranium-fuel-cell"
}
for _,name in pairs(vanilla_fuels) do
	local item = data.raw.item[name]
	if item then
		if not item.flags then item.flags = {} end
		table.insert(item.flags, "hide-from-fuel-tooltip")
	end
end

local vanilla_entities = {
	accumulator = {"accumulator"},
	["ammo-turret"] = {"gun-turret"},
	["arithmetic-combinator"] = {"arithmetic-combinator"},
	["artillery-turret"] = {"artillery-turret"},
	["artillery-wagon"] = {"artillery-wagon"},
	["assembling-machine"] = {"assembling-machine-1", "assembling-machine-2", "assembling-machine-3", "centrifuge", "chemical-plant", "oil-refinery"},
	beacon = {"beacon"},
	boiler = {"boiler", "heat-exchanger"},
	car = {"car", "tank"},
	["combat-robot"] = {"defender", "destroyer", "distractor"},
	["constant-combinator"] = {"constant-combinator"},
	["construction-robot"] = {"construction-robot"},
	container = {"iron-chest", "steel-chest", "wooden-chest"},
	["decider-combinator"] = {"decider-combinator"},
	["electric-pole"] = {"small-electric-pole", "medium-electric-pole", "big-electric-pole", "substation"},
	["electric-turret"] = {"laser-turret"},
	["fluid-turret"] = {"flamethrower-turret"},
	furnace = {"stone-furnace", "steel-furnace", "electric-furnace"},
	gate = {"gate"},
	generator = {"steam-engine", "steam-turbine"},
	["heat-pipe"] = {"heat-pipe"},
	inserter = {"burner-inserter", "fast-inserter", "filter-inserter", "inserter", "long-handed-inserter", "stack-filter-inserter", "stack-inserter"},
	lab = {"lab"},
	["land-mine"] = {"land-mine"},
	["logistic-container"] = {"logistic-chest-active-provider", "logistic-chest-buffer", "logistic-chest-passive-provider", "logistic-chest-requester", "logistic-chest-storage"},
	["logistic-robot"] = {"logistic-robot"},
	["mining-drill"] = {"burner-mining-drill", "electric-mining-drill", "pumpjack"},
	["offshore-pump"] = {"offshore-pump"},
	pipe = {"pipe"},
	["pipe-to-ground"] = {"pipe-to-ground"},
	["programmable-speaker"] = {"programmable-speaker"},
	pump = {"pump"},
	radar = {"radar"},
	reactor = {"nuclear-reactor"},
	roboport = {"roboport"},
	["rocket-silo"] = {"rocket-silo"},
	["solar-panel"] = {"solar-panel"},
	["spider-vehicle"] = {"spidertron"},
	splitter = {"splitter", "fast-splitter", "express-splitter"},
	["storage-tank"] = {"storage-tank"},
	["transport-belt"] = {"transport-belt", "fast-transport-belt", "express-transport-belt"},
	turret = {"small-worm-turret", "medium-worm-turret", "big-worm-turret", "behemoth-worm-turret"},
	["underground-belt"] = {"underground-belt", "fast-underground-belt", "express-underground-belt"},
	unit = {"small-biter", "medium-biter", "big-biter", "behemoth-biter", "small-spitter", "medium-spitter", "big-spitter", "behemoth-spitter", "compilatron"},
	["unit-spawner"] = {"biter-spawner", "spitter-spawner"},
	wall = {"stone-wall"}
}
for type,entities in pairs(vanilla_entities) do
	for _,name in pairs(entities) do
		local entity = data.raw[type][name]
		assert(entity, "Entity "..type.."."..name.." not found, check for typo")
		if not entity.flags then entity.flags = {} end
		table.insert(entity.flags, "hidden")

		entity.next_upgrade = nil
		if type == "combat-robot" or type == "turret" or type == "unit" or type == "unit-spawner" then
			entity.subgroup = "vanilla"
		end
	end
end
data.raw.cliff.cliff.cliff_explosive = nil

-- nuke achievements
for key in pairs(defines.prototypes.achievement) do
	data.raw[key] = {}
end

-- tiles don't give back anything
for _,tile in pairs(data.raw.tile) do
	if tile.minable then
		tile.minable.result = nil
	end
end

-- hide fluids
local vanilla_fluids = {"steam", "light-oil", "lubricant", "petroleum-gas"}
for _,key in pairs(vanilla_fluids) do
	local fluid = data.raw.fluid[key]
	fluid.hidden = true
	fluid.subgroup = "vanilla"
end
