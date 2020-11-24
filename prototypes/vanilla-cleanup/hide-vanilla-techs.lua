local vanillatechs = {
	"automation", "automation-2", "automation-3",
	"fast-inserter", "stack-inserter", "inserter-capacity-bonus-1", "inserter-capacity-bonus-2", "inserter-capacity-bonus-3", "inserter-capacity-bonus-4", "inserter-capacity-bonus-5", "inserter-capacity-bonus-6", "inserter-capacity-bonus-7",
	"electronics", "advanced-electronics", "advanced-electronics-2", "circuit-network",
	"explosives", "cliff-explosives",
	"logistics", "logistics-2", "logistics-3",
	"optics", "laser", "solar-energy",
	"stone-wall", "gate",
	"engine", "electric-engine", "lubricant",
	"battery", "electric-energy-accumulators",
	"landfill", "concrete",
	"braking-force-1", "braking-force-2", "braking-force-3", "braking-force-4", "braking-force-5", "braking-force-6", "braking-force-7",
	"chemical-science-pack", "logistic-science-pack", "military-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
	"steel-processing", "steel-axe", "advanced-material-processing", "advanced-material-processing-2",
	"electric-energy-distribution-1", "electric-energy-distribution-2",
	"railway", "automated-rail-transportation", "rail-signals", "fluid-wagon",
	"robotics", "construction-robotics", "logistic-robotics", "logistic-system", "personal-roboport-equipment", "personal-roboport-mk2-equipment",
	"worker-robots-speed-1", "worker-robots-speed-2", "worker-robots-speed-3", "worker-robots-speed-4",
	"worker-robots-storage-1", "worker-robots-storage-2", "worker-robots-storage-3",
	"mining-productivity-1", "mining-productivity-2", "mining-productivity-3", "mining-productivity-4", "worker-robots-speed-5", "worker-robots-speed-6",
	"toolbelt",
	"research-speed-1", "research-speed-2", "research-speed-3", "research-speed-4", "research-speed-5", "research-speed-6",
	"fluid-handling", "oil-processing", "sulfur-processing", "plastics", "advanced-oil-processing", "coal-liquefaction",
	"military", "military-2", "military-3", "military-4",
	"flammables", "flamethrower", "land-mine",
	"gun-turret", "laser-turret", "artillery",
	"automobilism", "tank", "spidertron",
	"uranium-ammo", "atomic-bomb",
	"rocketry", "explosive-rocketry",
	"energy-weapons-damage-1", "energy-weapons-damage-2", "energy-weapons-damage-3", "energy-weapons-damage-4", "energy-weapons-damage-5", "energy-weapons-damage-6", "energy-weapons-damage-7",
	"refined-flammables-1", "refined-flammables-2", "refined-flammables-3", "refined-flammables-4", "refined-flammables-5", "refined-flammables-6", "refined-flammables-7",
	"stronger-explosives-1", "stronger-explosives-2", "stronger-explosives-3", "stronger-explosives-4", "stronger-explosives-5", "stronger-explosives-6", "stronger-explosives-7",
	"weapon-shooting-speed-1", "weapon-shooting-speed-2", "weapon-shooting-speed-3", "weapon-shooting-speed-4", "weapon-shooting-speed-5", "weapon-shooting-speed-6",
	"artillery-shell-range-1", "artillery-shell-speed-1",
	"physical-projectile-damage-1", "physical-projectile-damage-2", "physical-projectile-damage-3", "physical-projectile-damage-4", "physical-projectile-damage-5", "physical-projectile-damage-6", "physical-projectile-damage-7",
	"laser-shooting-speed-1", "laser-shooting-speed-2", "laser-shooting-speed-3", "laser-shooting-speed-4", "laser-shooting-speed-5", "laser-shooting-speed-6", "laser-shooting-speed-7",
	"defender", "distractor", "destroyer",
	"follower-robot-count-1", "follower-robot-count-2", "follower-robot-count-3", "follower-robot-count-4", "follower-robot-count-5", "follower-robot-count-6", "follower-robot-count-7",
	"uranium-processing", "nuclear-power", "nuclear-fuel-reprocessing", "kovarex-enrichment-process",
	"heavy-armor", "modular-armor", "power-armor", "power-armor-mk2",
	"energy-shield-equipment", "energy-shield-mk2-equipment", "night-vision-equipment", "belt-immunity-equipment", "exoskeleton-equipment",
	"battery-equipment", "battery-mk2-equipment", "solar-panel-equipment", "fusion-reactor-equipment",
	"personal-laser-defense-equipment", "discharge-defense-equipment",
	"modules", "effect-transmission",
	"speed-module", "speed-module-2", "speed-module-3",
	"productivity-module", "productivity-module-2", "productivity-module-3",
	"effectivity-module", "effectivity-module-2", "effectivity-module-3",
	"low-density-structure", "rocket-control-unit", "rocket-fuel", "rocket-silo"
}
for _, tech in pairs(vanillatechs) do
	data.raw.technology[tech] = nil
end

-- remove other things that depend on vanilla techs
for _,s in pairs(data.raw.shortcut) do
	if s.technology_to_unlock == "construction-robotics" then
		s.technology_to_unlock = nil
	end
end
data.raw['research-achievement'] = {}

local tips = data.raw['tips-and-tricks-item']
tips['long-handed-inserters'].trigger = {type="build-entity",entity="long-handed-inserter"}
tips['splitters'].trigger = {type="build-entity",entity="splitter"}
tips['underground-belts'].trigger = {type="build-entity",entity="underground-belt"}
tips['trains'].trigger.technology = "hub-tier6-monorail-train-technology"
tips['train-stops'].trigger = tips['train-stops'].trigger.triggers[1]
tips['rail-signals-basic'].trigger.triggers[2].triggers[1].technology = "hub-tier6-monorail-train-technology"
tips['gate-over-rail'].trigger.triggers[3] = {type="build-entity",entity="gate"}
tips['logistic-network'].trigger = {type="build-entity",entity="roboport"}
tips['personal-logistics'].trigger = {type="build-entity",entity="roboport"}
tips['construction-robots'].trigger = {type="build-entity",entity="roboport"}
tips['requester-chest'].trigger = {type="build-entity",entity="logistic-chest-requester"}
tips['active-provider-chest'].trigger = {type="build-entity",entity="logistic-chest-active-provider"}
tips['buffer-chest'].trigger = {type="build-entity",entity="logistic-chest-buffer"}
tips['ghost-building'].trigger = {type="build-entity",entity="transport-belt",count=100}
tips['circuit-network'].trigger = {type="build-entity",entity="logistic-chest-storage"}
