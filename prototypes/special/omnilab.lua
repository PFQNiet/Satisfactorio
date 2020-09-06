-- a special, (TODO invisible) lab that accepts all of the "fake" items used to progress the game
local lab = table.deepcopy(data.raw.lab.lab)
lab.name = "omnilab"
lab.collision_mask = {}
lab.energy_usage = "1W"
lab.energy_source = {type="void"}
lab.allowed_effects = {}
lab.module_specification = nil
lab.minable.result = lab.name
lab.max_health = 1
lab.inputs = {
	"hub-tier0-hub-upgrade-1",
	"hub-tier0-hub-upgrade-2",
	"hub-tier0-hub-upgrade-3",
	"hub-tier0-hub-upgrade-4",
	"hub-tier0-hub-upgrade-5",
	"hub-tier0-hub-upgrade-6",
}

local labitem = table.deepcopy(data.raw.item.lab)
labitem.name = lab.name
labitem.place_result = lab.name

data:extend({lab,labitem})