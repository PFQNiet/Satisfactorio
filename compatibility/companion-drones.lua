-- add compatibility for Companion Drones
local mod = "Companion_Drones"
if mods[mod] then
	-- disable drone equipment recipes - these are auto-added to the drone when placed
	data.raw.recipe['companion-reactor-equipment'] = nil
	data.raw.recipe['companion-shield-equipment'] = nil
	data.raw.recipe['companion-roboport-equipment'] = nil
	data.raw.recipe['companion-defense-equipment'] = nil
	-- modify the base companion recipe
	local recipe = data.raw.recipe['companion']
	recipe.category = "equipment"
	recipe.energy_required = 12/4
	-- replace green circuits with a.i. limiter
	recipe.ingredients = { -- originally 100x green circuit, 50x gear, 50x iron plate, 50x cable, 1x fish
		{"processing-unit",5},
		{"iron-gear-wheel",250},
		{"reinforced-iron-plate",100},
		{"copper-cable",100}
	} -- this recipe is set up to allow "rushing" the caterium research tree to get them
	recipe.enabled = false
	recipe.hide_from_stats = true

	-- adjust vehicle
	local spider = data.raw['spider-vehicle']['companion']
	spider.max_health = 1
	spider.resistances = nil
	spider.movement_energy_consumption = "10MW"

	data.raw['item-subgroup']['companion'].group = 'logistics'

	-- lock the equipment grid
	local grid = data.raw['equipment-grid']['companion-equipment-grid']
	grid.width = 4
	grid.locked = true

	-- by default these are available from the start of the game, so let's move them to the Caterium MAM tree to allow for rushing them if desired
	local addTech = require("prototypes.technology")
	local tech = addTech("mam-caterium-companion-drone", {
		filename = "__"..mod.."__/drone-icon.png",
		size = 200
	}, "mam", "mam-caterium", "m-2-9-[companion-drone]", 3, {"mam-caterium-ai-limiter"}, {
		{"processing-unit",10},
		{"iron-gear-wheel",500}
	}, {
		{type="unlock-recipe",recipe='companion'}
	}, {"companion"})
end
