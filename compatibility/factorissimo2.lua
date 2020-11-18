-- add compatibility for Factorissimo2
local mod = "Factorissimo2"
if mods[mod] then
	local function removeTech(k)
		local tech = data.raw.technology[k]
		tech.enabled = false
		tech.hidden = true
		tech.prerequisites = {}
	end

	-- add the factory buildings to "Base Building" milestone, however the recipes will restrict you to smaller buildings until later tiers
	table.insert(data.raw.technology['hub-tier1-base-building'].effects, {type="unlock-recipe",recipe="factory-1"})
	table.insert(data.raw.technology['hub-tier1-base-building'].effects, {type="unlock-recipe",recipe="factory-2"})
	table.insert(data.raw.technology['hub-tier1-base-building'].effects, {type="unlock-recipe",recipe="factory-3"})
	-- delete the base techs from Factorissimo
	removeTech("factory-architecture-t1")
	removeTech("factory-architecture-t2")
	removeTech("factory-architecture-t3")
	
	-- add fluid connectors to "Coal Power" milestone since that's when you unlock pipes
	table.insert(data.raw.technology['hub-tier3-coal-power'].effects, {type="unlock-recipe",recipe="factory-input-pipe"})
	table.insert(data.raw.technology['hub-tier3-coal-power'].effects, {type="unlock-recipe",recipe="factory-output-pipe"})
	-- delete the connection techs from Factorissimo (notably, chests wouldn't work here, so belts only)
	removeTech("factory-connection-type-fluid")
	removeTech("factory-connection-type-chest")
	removeTech("factory-connection-type-circuit")

	-- set interior upgrades as dependents of Base Building and make them free but also hidden
	-- the control script can set them as researched when Base Building is researched
	for _,k in pairs({"factory-interior-upgrade-lights", "factory-interior-upgrade-display", "factory-preview", "factory-recursion-t1", "factory-recursion-t2"}) do
		local tech = data.raw.technology[k]
		tech.hidden = true
		tech.prerequisites = {"hub-tier1-base-building"}
		tech.unit = {
			count = 1,
			time = 1,
			ingredients = {}
		}
	end

	-- disable the requester chest tech
	removeTech("factory-requester-chest")

	-- recipe changes
	local building = data.raw['storage-tank']['factory-1']
	building.max_health = 1
	local item = data.raw.item[building.name]
	local recipe = data.raw.recipe['factory-1']
	recipe.energy_required = 10
	recipe.category = "building"
	recipe.ingredients = {{"concrete",250},{"iron-plate",250}}
	local _group = data.raw['item-subgroup'][item.subgroup]
	local undo = {
		type = "recipe",
		name = item.name.."-undo",
		localised_name = {"recipe-name.dismantle",{"entity-name."..item.name}},
		localised_description = {"mod-compatibility.factorissimo2-cannot-dismantle-after-placing"},
		ingredients = {{building.name,1}},
		results = recipe.ingredients,
		energy_required = 10,
		category = "unbuilding",
		subgroup = _group.group.."-undo",
		order = _group.order.."-"..item.order,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		icons = {
			{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
			{icon = item.icon, icon_size = item.icon_size}
		},
		enabled = false
	}
	data:extend{undo}

	building = data.raw['storage-tank']['factory-2']
	building.max_health = 1
	item = data.raw.item[building.name]
	recipe = data.raw.recipe['factory-2']
	recipe.energy_required = 15
	recipe.category = "building"
	recipe.ingredients = {{"concrete",500},{"steel-plate",250}}
	_group = data.raw['item-subgroup'][data.raw.item[item.name].subgroup]
	undo = {
		type = "recipe",
		name = item.name.."-undo",
		localised_name = {"recipe-name.dismantle",{"entity-name."..item.name}},
		localised_description = {"mod-compatibility.factorissimo2-cannot-dismantle-after-placing"},
		ingredients = {{item.name,1}},
		results = recipe.ingredients,
		energy_required = 15,
		category = "unbuilding",
		subgroup = _group.group.."-undo",
		order = _group.order.."-"..item.order,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		icons = {
			{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
			{icon = item.icon, icon_size = item.icon_size}
		},
		enabled = false
	}
	data:extend{undo}

	building = data.raw['storage-tank']['factory-3']
	building.max_health = 1
	item = data.raw.item[building.name]
	recipe = data.raw.recipe['factory-3']
	recipe.energy_required = 20
	recipe.category = "building"
	recipe.ingredients = {{"concrete",1000},{"alclad-aluminium-sheet",500}}
	_group = data.raw['item-subgroup'][data.raw.item[item.name].subgroup]
	undo = {
		type = "recipe",
		name = item.name.."-undo",
		localised_name = {"recipe-name.dismantle",{"entity-name."..item.name}},
		localised_description = {"mod-compatibility.factorissimo2-cannot-dismantle-after-placing"},
		ingredients = {{item.name,1}},
		results = recipe.ingredients,
		energy_required = 20,
		category = "unbuilding",
		subgroup = _group.group.."-undo",
		order = _group.order.."-"..item.order,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		icons = {
			{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
			{icon = item.icon, icon_size = item.icon_size}
		},
		enabled = false
	}
	data:extend{undo}

	building = data.raw['storage-tank']['factory-input-pipe']
	building.max_health = 1
	building.fluid_box.base_area = 0.02
	item = data.raw.item[building.name]
	recipe = data.raw.recipe['factory-input-pipe']
	recipe.energy_required = 2
	recipe.category = "building"
	recipe.ingredients = {{"copper-plate",2}}
	_group = data.raw['item-subgroup'][data.raw.item[item.name].subgroup]
	undo = {
		type = "recipe",
		name = item.name.."-undo",
		localised_name = {"recipe-name.dismantle",{"entity-name."..item.name}},
		ingredients = {{item.name,1}},
		results = recipe.ingredients,
		energy_required = 2,
		category = "unbuilding",
		subgroup = _group.group.."-undo",
		order = _group.order.."-"..item.order,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		icons = {
			{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
			{icon = item.icon, icon_size = item.icon_size}
		},
		enabled = false
	}
	data:extend{undo}
	
	building = data.raw['storage-tank']['factory-output-pipe']
	building.max_health = 1
	building.fluid_box.base_area = 0.02
	item = data.raw.item[building.name]
	recipe = data.raw.recipe['factory-output-pipe']
	recipe.energy_required = 2
	recipe.category = "building"
	recipe.ingredients = {{"copper-plate",2}}
	_group = data.raw['item-subgroup'][data.raw.item[item.name].subgroup]
	undo = {
		type = "recipe",
		name = item.name.."-undo",
		localised_name = {"recipe-name.dismantle",{"entity-name."..item.name}},
		ingredients = {{item.name,1}},
		results = recipe.ingredients,
		energy_required = 2,
		category = "unbuilding",
		subgroup = _group.group.."-undo",
		order = _group.order.."-"..item.order,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		icons = {
			{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
			{icon = item.icon, icon_size = item.icon_size}
		},
		enabled = false
	}
	data:extend{undo}
end
