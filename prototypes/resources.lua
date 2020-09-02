-- create custom resources
require("prototypes.resources.caterium-ore")

local dataResource = data.raw.resource
-- overhaul vanilla ores
local resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","crude-oil"}
for _, res in ipairs(resources) do
	dataResource[res].autoplace = nil
end
-- remove sulfuric acid as requirement for uranium, as it will be part of the refining process
local uraniumMining = dataResource['uranium-ore'].minable
uraniumMining.required_fluid = nil
uraniumMining.fluid_amount = 0
uraniumMining.mining_time = 1

-- change ore thresholds to use impure/normal/pure thresholds
resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","caterium-ore"}
for _, res in ipairs(resources) do
	dataResource[res].stage_counts = {240,200,120,80,60,0,0,0}
end

-- make ores infinite
resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","crude-oil","caterium-ore"}
for _, res in ipairs(resources) do
	local resource = dataResource[res]
	resource.infinite = true
	resource.infinite_depletion_amount = 0
	resource.minimum = 1
	resource.normal = 60
	resource.map_grid = false
	resource.resource_patch_search_radius = 1
end
-- change oil value to scale as m^3
dataResource['crude-oil'].collision_box = {{-0.1,-0.1},{0.1,0.1}}
dataResource['crude-oil'].highlight = false
dataResource['crude-oil'].minable.results = {{
	type = "fluid",
	name = "crude-oil",
	amount_min = 0.5, -- originally 10
	amount_max = 0.5, -- originally 10
	probability = 1
}}
