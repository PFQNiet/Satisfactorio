-- create custom resources
require("prototypes.resources.caterium-ore")

local function overhaulVanillaOres()
	local resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","crude-oil"}
	for i, res in ipairs(resources) do
		data.raw.resource[res].autoplace = nil
	end
	-- remove sulfuric acid as requirement for uranium, as it will be part of the refining process
	data.raw.resource['uranium-ore'].minable.required_fluid = nil
	data.raw.resource['uranium-ore'].minable.fluid_amount = 0
	data.raw.resource['uranium-ore'].minable.mining_time = 1
end
overhaulVanillaOres()

local function normaliseOreSprites()
	-- change ore thresholds to use impure/normal/pure thresholds
	local resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","caterium-ore"}
	for i, res in ipairs(resources) do
		data.raw.resource[res].stage_counts = {240,200,120,80,60,0,0,0}
	end
end
normaliseOreSprites()

local function adjustResourceValues()
	local resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","crude-oil","caterium-ore"}
	for i, res in ipairs(resources) do
		data.raw.resource[res].infinite = true
		data.raw.resource[res].infinite_depletion_amount = 0
		data.raw.resource[res].minimum = 1
		data.raw.resource[res].normal = 60
		data.raw.resource[res].map_grid = false
		data.raw.resource[res].resource_patch_search_radius = 1
	end
	data.raw.resource['crude-oil'].minable.results = {{
		type = "fluid",
		name = "crude-oil",
		amount_min = 0.5,
		amount_max = 0.5,
		probability = 1
	}}
end
adjustResourceValues()
