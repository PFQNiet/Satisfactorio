local name = "space-elevator"
local elevator = makeAssemblingMachine{
	name = name,
	size = {27,27},
	category = "space-elevator",
	subgroup = "special",
	order = "e",
	ingredients = {
		{"concrete",500},
		{"iron-plate",250},
		{"iron-rod",400},
		{"wire",1500}
	}
}
elevator.machine.draw_entity_info_icon_background = false
elevator.machine.return_ingredients_on_change = false
elevator.machine.minable.mining_time = 5
elevator.item.stack_size = 1

local silo = table.deepcopy(data.raw['rocket-silo']['rocket-silo'])
silo.name = "space-elevator-silo"
silo.localised_name = {"entity-name."..name}
silo.energy_source = {type="void"}
silo.rocket_parts_required = 1
silo.max_health = 1
silo.fixed_recipe = nil
silo.minable = nil
silo.selectable_in_game = false
silo.flags = {}
data:extend{silo}

--[[ suspect this is unused
local siloitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = silo.name,
	flags = {"hidden"},
	order = "e["..silo.name.."]",
	subgroup = "special",
	stack_size = 1,
	type = "item"
}
]]

-- data:extend({silo,siloitem})
