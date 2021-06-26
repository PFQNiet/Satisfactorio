-- add compatibility for Factorissimo2
local mod = "Factorissimo2"
if mods[mod] then
	local function hideTech(k)
		local tech = data.raw.technology[k]
		tech.hidden = true
		tech.prerequisites = {}
		tech.unit = {
			count = 1,
			time = 1,
			ingredients = {}
		}
	end
	local function removeTech(k)
		local tech = data.raw.technology[k]
		tech.enabled = false
		tech.hidden = true
		tech.prerequisites = {}
		tech.effects = {}
	end
	local function hideItem(k)
		local item = data.raw.item[k]
		if not item.flags then item.flags = {} end
		table.insert(item.flags,"hidden")
		data.raw.recipe[k] = nil
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
	hideTech("factory-connection-type-fluid")
	removeTech("factory-connection-type-chest")
	removeTech("factory-connection-type-circuit")

	-- set interior upgrades as dependents of Base Building and make them free but also hidden
	-- the control script can set them as researched when Base Building is researched
	hideTech("factory-interior-upgrade-lights")
	hideTech("factory-interior-upgrade-display")
	hideTech("factory-preview")
	hideTech("factory-recursion-t1")
	hideTech("factory-recursion-t2")

	-- disable the requester chest tech
	removeTech("factory-requester-chest")

	-- recipe changes
	local costs = {
		{
			{"concrete", 250},
			{"iron-plate", 200}
		},
		{
			{"concrete", 500},
			{"steel-beam", 200}
		},
		{
			{"concrete", 1000},
			{"alclad-aluminium-sheet", 400}
		}
	}
	for i, ingredients in pairs(costs) do
		local building = data.raw['storage-tank']['factory-'..i]
		building.max_health = 1
		local item = data.raw.item['factory-'..i]
		if not item.flags then item.flags = {} end
		table.insert(item.flags, "only-in-cursor")
		data.raw.recipe['factory-'..i] = makeBuildingRecipe{
			name = "factory-"..i,
			ingredients = ingredients,
			result = "factory-"..i
		}
	end

	building = data.raw['storage-tank']['factory-input-pipe']
	building.max_health = 1
	building.fluid_box.base_area = 0.1
	data.raw.recipe['factory-input-pipe'] = makeBuildingRecipe{
		name = "factory-input-pipe",
		ingredients = {{"copper-sheet",2}},
		result = "factory-input-pipe"
	}

	building = data.raw['storage-tank']['factory-output-pipe']
	building.max_health = 1
	building.fluid_box.base_area = 0.1
	data.raw.recipe['factory-output-pipe'] = makeBuildingRecipe{
		name = "factory-output-pipe",
		ingredients = {{"copper-sheet",2}},
		result = "factory-output-pipe"
	}

	-- hide circuit in/output and requester
	hideItem("factory-circuit-input")
	hideItem("factory-circuit-output")
	hideItem("factory-requester-chest")
end
