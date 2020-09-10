local silo = table.deepcopy(data.raw['rocket-silo']['rocket-silo'])

silo.name = "ficsit-freighter"
silo.collision_box = {{-1.3,-1.3},{1.3,1.3}}
silo.selection_box = {{-1.5,-1.5},{1.5,1.5}}
silo.energy_source = {type="void"}
silo.rocket_parts_required = 1
silo.max_health = 1

local siloitem = {
	icon = "__Satisfactorio__/graphics/icons/the-hub.png",
	icon_size = 64,
	name = silo.name,
	flags = {"hidden"},
	order = "a["..silo.name.."]",
	subgroup = "special",
	stack_size = 1,
	type = "item"
}

data:extend({silo,siloitem})
