-- remove autoplacement of rock entities
local rock = data.raw['simple-entity']['rock-big']
local hugerock = data.raw['simple-entity']['rock-huge']
local sandyrock = data.raw['simple-entity']['sand-rock-big']

rock.autoplace = nil
rock.loot = nil
hugerock.autoplace = nil
hugerock.minable = nil
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
		mining_time = 6,
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
data.raw['simple-entity']['rock-big-uranium-ore'].emissions_per_second = 12.5/60

hugerock.max_health = 1
hugerock.collision_box = {{-1.5*1.5,-1.1*1.5},{1.5*1.5,1.1*1.5}}
hugerock.selection_box = {{-1.7*1.5,-1.3*1.5},{1.7*1.5,1.3*1.5}}
hugerock.selection_priority = 55
for _,pic in pairs(hugerock.pictures) do
	pic.scale = 1.5
	pic.hr_version.scale = 0.75
end
-- make vulnerable to nobelisk damage
if not hugerock.trigger_target_mask then hugerock.trigger_target_mask = data.raw['utility-constants'].default.default_trigger_target_mask_by_type['simple-entity'] or {'common'} end
table.insert(hugerock.trigger_target_mask, "nobelisk-explodable")

data:extend({
	{
		type = "autoplace-control",
		name = "x-plant",
		order = "r",
		richness = false,
		category = "terrain"
	},
	{
		type = "noise-layer",
		name = "x-plant"
	}
})

data:extend({
	{
		type = "autoplace-control",
		name = "x-deposit",
		order = "s",
		richness = false,
		category = "terrain"
	},
	{
		type = "noise-layer",
		name = "x-deposit"
	}
})
