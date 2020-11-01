-- remove autoplacement of rock entities
local rock = data.raw['simple-entity']['rock-big']
local hugerock = data.raw['simple-entity']['rock-huge']
local sandyrock = data.raw['simple-entity']['sand-rock-big']

rock.autoplace = nil
rock.loot = nil
hugerock.autoplace = nil
hugerock.loot = nil
sandyrock.autoplace = nil
sandyrock.loot = nil

local resources = {
	["iron-ore"] = {0.415,0.525,1},
	["copper-ore"] = {0.803,0.388,0.215},
	["stone"] = {1,1,1},
	["coal"] = {0,0,0},
	["caterium-ore"] = {0.8,0.8,0},
	["raw-quartz"] = {0.8,0,0.8},
	["sulfur"] = {1,1,0.4},
	["uranium-ore"] = {0,0.7,0},
	["bauxite"] = {0.8,0.2,0}
}

-- clone the rock and tweak it for each resource type
for resource,colour in pairs(resources) do
	local deposit = rock
	if resource ~= "stone" then
		deposit = table.deepcopy(deposit)
		deposit.name = deposit.name.."-"..resource
	end
	deposit.localised_name = {"entity-name.resource-deposit",{"item-name."..resource}}
	deposit.minable = {
		mining_time = 10,
		mining_particle = "stone-particle",
		results = {{
			name = resource,
			amount_min = 30,
			amount_max = 60
		}}
	}

	-- scale colour to just be a slight tint
	colour = {
		1-(1-colour[1])/2,
		1-(1-colour[2])/2,
		1-(1-colour[3])/2
	}
	for _,pic in pairs(deposit.pictures) do
		pic.tint = colour
		pic.hr_version.tint = colour
	end

	if resource ~= "stone" then
		data:extend{deposit}
	end
end

hugerock.max_health = 1
