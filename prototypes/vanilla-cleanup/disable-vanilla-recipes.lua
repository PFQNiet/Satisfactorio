local to_disable = {
	"wooden-chest",
	"iron-chest",
	"burner-inserter",
	"inserter",
	"small-electric-pole",
	"pipe",
	"pipe-to-ground",
	"stone-brick",
	"repair-pack",
	"boiler",
	"steam-engine",
	"burner-mining-drill",
	"electric-mining-drill",
	"offshore-pump",
	"stone-furnace",
	"lab",
	"iron-gear-wheel",
	"electronic-circuit",
	"automation-science-pack",
	"pistol",
	"firearm-magazine",
	"light-armor",
	"radar"
}

for _,key in ipairs(to_disable) do
	local recipe = data.raw.recipe[key]
	if recipe.enabled ~= nil or recipe.normal == nil then
		recipe.enabled = false
	end
	if recipe.normal and (recipe.normal.enabled ~= nil or recipe.enabled == nil) then
		recipe.normal.enabled = false
	end
	if recipe.expensive and (recipe.expensive.enabled ~= nil or recipe.enabled == nil) then
		recipe.expensive.enabled = false
	end
end

local to_hide = {
	"storage-tank",
	"splitter", "fast-splitter", "express-splitter",
	"burner-inserter", "inserter", "long-handed-inserter", "fast-inserter", "filter-inserter", "stack-inserter", "stack-filter-inserter",
	"substation",
	"train-stop", "artillery-wagon", "car", "tank", "spidertron", "spidertron-remote",
	"logistic-robot", "construction-robot", "logistic-chest-active-provider", "logistic-chest-passive-provider", "logistic-chest-storage", "logistic-chest-buffer", "logistic-chest-requester", "roboport",
	"small-lamp", "red-wire", "green-wire", "arithmetic-combinator", "decider-combinator", "constant-combinator", "power-switch", "programmable-speaker",
	"stone-brick", "hazard-concrete", "refined-concrete", "refined-hazard-concrete", "landfill", "cliff-explosives",
	"repair-pack",
	"boiler", "steam-engine", "solar-panel", "accumulator", "nuclear-reactor", "heat-pipe", "heat-exchanger", "steam-turbine",
	"burner-mining-drill", "electric-mining-drill", "offshore-pump", "pumpjack",
	"stone-furnace", "steel-furnace", "electric-furnace",
	"assembling-machine-1", "assembling-machine-2", "assembling-machine-3", "oil-refinery", "chemical-plant", "centrifuge", "lab",
	"beacon", "speed-module", "speed-module-2", "speed-module-3", "effectivity-module", "effectivity-module-2", "effectivity-module-3", "productivity-module", "productivity-module-2", "productivity-module-3",
	"solid-fuel", "explosives",
	"iron-gear-wheel", "empty-barrel", "engine-unit", "electric-engine-unit", "flying-robot-frame", "satellite", "rocket-control-unit", "low-density-structure", "rocket-fuel", "uranium-235", "uranium-238", "used-up-uranium-fuel-cell",
	"automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
	"shotgun", "combat-shotgun", "rocket-launcher", "flamethrower", "land-mine",
	"piercing-rounds-magazine", "uranium-rounds-magazine", "shotgun-shell", "piercing-shotgun-shell", "cannon-shell", "explosive-cannon-shell", "uranium-cannon-shell", "explosive-uranium-cannon-shell",
	"artillery-shell", "rocket", "explosive-rocket", "atomic-bomb", "flamethrower-ammo",
	"grenade", "cluster-grenade", "poison-capsule", "slowdown-capsule", "defender-capsule", "distractor-capsule", "destroyer-capsule",
	"light-armor", "heavy-armor", "modular-armor", "power-armor", "power-armor-mk2",
	"solar-panel-equipment", "fusion-reactor-equipment", "battery-equipment", "battery-mk2-equipment", "belt-immunity-equipment", "personal-roboport-equipment", "personal-roboport-mk2-equipment", "night-vision-equipment",
	"energy-shield-equipment", "energy-shield-mk2-equipment", "personal-laser-defense-equipment", "discharge-defense-equipment", "discharge-defense-remote",
	"gate", "gun-turret", "laser-turret", "flamethrower-turret", "artillery-turret", "artillery-targeting-remote", "rocket-silo"
}
for _,key in pairs(to_hide) do
	local item = data.raw.item[key] or data.raw['item-with-entity-data'][key] or data.raw.tool[key] or data.raw.module[key]
		or data.raw.gun[key] or data.raw.ammo[key] or data.raw.capsule[key] or data.raw.armor[key]
		or data.raw['spidertron-remote'][key] or data.raw['repair-tool'][key]
	if not item.flags then item.flags = {} end
	table.insert(item.flags, "hidden")
end
table.insert(data.raw.item['solid-fuel'].flags, "hide-from-fuel-tooltip")
table.insert(data.raw.item['rocket-fuel'].flags, "hide-from-fuel-tooltip")
-- remove next-upgrade
for _,group in pairs(data.raw) do
	for _,thing in pairs(group) do
		if thing.next_upgrade then thing.next_upgrade = nil end
	end
end
-- hide fluids
to_hide = {"steam", "light-oil", "lubricant", "petroleum-gas"}
for _,key in pairs(to_hide) do
	data.raw.fluid[key].hidden = true
end
