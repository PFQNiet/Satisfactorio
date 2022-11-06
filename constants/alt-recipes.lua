---@class AltRecipeEntry
---@field name string
---@field ingredients Ingredient[]
---@field result Product
---@field result_count uint
---@field results Product[]
---@field main_product Product
---@field subgroup string
---@field energy_required number
---@field category '"constructing"'|'"assembling"'|'"manufacturing"'|'"smelter"'|'"foundry"'|'"refining"'|'"blending"'|'"accelerating"'
---@field icons ItemPrototypeIdentification[]
---@field prerequisites TechnologyIdentification[]

---@type AltRecipeEntry[]
local recipes = {
	{
		name = "copper-alloy-ingot",
		ingredients = {
			{"copper-ore",10},
			{"iron-ore",5}
		},
		result = "copper-ingot",
		result_count = 20,
		energy_required = 12,
		category = "foundry",
		icons = {"iron-ore"},
		prerequisites = {}
	},
	{
		name = "fine-black-powder",
		ingredients = {
			{"sulfur",2},
			{"compacted-coal",1}
		},
		result = "black-powder",
		result_count = 4,
		energy_required = 16,
		category = "assembling",
		icons = {"compacted-coal"},
		prerequisites = {"alt-compacted-coal"}
	},
	{
		name = "caterium-wire",
		ingredients = {
			{"caterium-ingot",1}
		},
		result = "wire",
		result_count = 8,
		energy_required = 4,
		category = "constructing",
		icons = {"caterium-ingot"},
		prerequisites = {"mam-caterium-caterium"}
	},
	{
		name = "fused-quickwire",
		ingredients = {
			{"caterium-ingot",1},
			{"copper-ingot",5}
		},
		result = "quickwire",
		result_count = 12,
		energy_required = 8,
		category = "assembling",
		icons = {"copper-ingot"},
		prerequisites = {"mam-caterium-caterium-ingots"}
	},
	{
		name = "fused-wire",
		ingredients = {
			{"copper-ingot",4},
			{"caterium-ingot",1}
		},
		result = "wire",
		result_count = 30,
		energy_required = 20,
		category = "assembling",
		icons = {"copper-ingot","caterium-ingot"},
		prerequisites = {"mam-caterium-caterium"}
	},
	{
		name = "fine-concrete",
		ingredients = {
			{"silica",3},
			{"stone",12}
		},
		result = "concrete",
		result_count = 10,
		energy_required = 24,
		category = "assembling",
		icons = {"silica"},
		prerequisites = {"mam-quartz-quartz"}
	},
	{
		name = "cheap-silica",
		ingredients = {
			{"raw-quartz",3},
			{"stone",5}
		},
		result = "silica",
		result_count = 7,
		energy_required = 16,
		category = "assembling",
		icons = {"stone"},
		prerequisites = {"mam-quartz-silica"}
	},
	{
		name = "seismic-nobelisk",
		ingredients = {
			{"black-powder",8},
			{"steel-pipe",8},
			{"crystal-oscillator",1}
		},
		result = "nobelisk",
		result_count = 4,
		energy_required = 40,
		category = "manufacturing",
		icons = {"crystal-oscillator"},
		prerequisites = {"mam-sulfur-nobelisk","mam-quartz-quartz-crystals"}
	},
	{
		name = "turbo-blend-fuel",
		ingredients = {
			{type="fluid",name="fuel",amount=2},
			{type="fluid",name="heavy-oil",amount=4},
			{"sulfur",3},
			{"petroleum-coke",3}
	},
		results = {{type="fluid",name="turbofuel",amount=6}},
		main_product = "turbofuel",
		subgroup = "fluid-recipe",
		energy_required = 8,
		category = "blending",
		icons = {"fuel", "heavy-oil-residue"},
		prerequisites = {"mam-sulfur-sulfur","hub-tier7-bauxite-refinement"}
	},
	{
		name = "iron-wire",
		ingredients = {
			{"iron-ingot",5}
		},
		result = "wire",
		result_count = 9,
		energy_required = 24,
		category = "constructing",
		icons = {"iron-ingot"},
		prerequisites = {}
	},
	{
		name = "cast-screw",
		ingredients = {
			{"iron-ingot",5}
		},
		result = "screw",
		result_count = 20,
		energy_required = 24,
		category = "constructing",
		icons = {"iron-ingot"},
		prerequisites = {}
	},
	{
		name = "iron-alloy-ingot",
		ingredients = {
			{"iron-ore",2},
			{"copper-ore",2}
		},
		result = "iron-ingot",
		result_count = 5,
		energy_required = 6,
		category = "foundry",
		icons = {"copper-ore"},
		prerequisites = {}
	},
	{
		name = "bolted-iron-plate",
		ingredients = {
			{"iron-plate",18},
			{"screw",50}
		},
		result = "reinforced-iron-plate",
		result_count = 3,
		energy_required = 12,
		category = "assembling",
		icons = {"screw"},
		prerequisites = {}
	},
	{
		name = "stitched-iron-plate",
		ingredients = {
			{"iron-plate",10},
			{"wire",20}
		},
		result = "reinforced-iron-plate",
		result_count = 3,
		energy_required = 32,
		category = "assembling",
		icons = {"wire"},
		prerequisites = {}
	},
	{
		name = "bolted-frame",
		ingredients = {
			{"reinforced-iron-plate",3},
			{"screw",56}
		},
		result = "modular-frame",
		result_count = 2,
		energy_required = 24,
		category = "assembling",
		icons = {"screw"},
		prerequisites = {"hub-tier2-part-assembly"}
	},
	{
		name = "copper-rotor",
		ingredients = {
			{"copper-sheet",6},
			{"screw",52}
		},
		result = "rotor",
		result_count = 3,
		energy_required = 16,
		category = "assembling",
		icons = {"copper-sheet"},
		prerequisites = {"hub-tier2-part-assembly"}
	},
	{
		name = "steel-rod",
		ingredients = {
			{"steel-ingot",1}
		},
		result = "iron-rod",
		result_count = 4,
		energy_required = 5,
		category = "constructing",
		icons = {"steel-ingot"},
		prerequisites = {"hub-tier3-basic-steel-production"}
	},
	{
		name = "steeled-frame",
		ingredients = {
			{"reinforced-iron-plate",2},
			{"steel-pipe",10}
		},
		result = "modular-frame",
		result_count = 3,
		energy_required = 60,
		category = "assembling",
		icons = {"steel-pipe"},
		prerequisites = {"hub-tier3-basic-steel-production"}
	},
	{
		name = "steel-rotor",
		ingredients = {
			{"steel-pipe",2},
			{"wire",6}
		},
		result = "rotor",
		result_count = 1,
		energy_required = 12,
		category = "assembling",
		icons = {"steel-pipe"},
		prerequisites = {"hub-tier3-basic-steel-production"}
	},
	{
		name = "steel-screw",
		ingredients = {
			{"steel-beam",1}
		},
		result = "screw",
		result_count = 52,
		energy_required = 12,
		category = "constructing",
		icons = {"steel-beam"},
		prerequisites = {"hub-tier3-basic-steel-production"}
	},
	{
		name = "solid-steel-ingot",
		ingredients = {
			{"iron-ingot",2},
			{"coal",2}
		},
		result = "steel-ingot",
		result_count = 3,
		energy_required = 3,
		category = "foundry",
		icons = {"iron-ingot"},
		prerequisites = {"hub-tier3-basic-steel-production"}
	},
	{
		name = "compacted-steel-ingot",
		ingredients = {
			{"iron-ore",6},
			{"compacted-coal",3}
		},
		result = "steel-ingot",
		result_count = 10,
		energy_required = 16,
		category = "foundry",
		icons = {"compacted-coal"},
		prerequisites = {"hub-tier3-basic-steel-production","alt-compacted-coal"}
	},
	{
		name = "crystal-beacon",
		ingredients = {
			{"steel-beam",4},
			{"steel-pipe",16},
			{"crystal-oscillator",1}
		},
		result = "map-marker",
		result_count = 20,
		energy_required = 120,
		category = "manufacturing",
		icons = {"crystal-oscillator"},
		prerequisites = {"hub-tier3-basic-steel-production","mam-quartz-quartz-crystals"}
	},
	{
		name = "biocoal",
		ingredients = {
			{"biomass",5}
		},
		result = "coal",
		result_count = 6,
		energy_required = 8,
		category = "constructing",
		icons = {"biomass"},
		prerequisites = {"hub-tier3-coal-power"}
	},
	{
		name = "charcoal",
		ingredients = {
			{"wood",1}
		},
		result = "coal",
		result_count = 10,
		energy_required = 4,
		category = "constructing",
		icons = {"wood"},
		prerequisites = {"hub-tier3-coal-power"}
	},
	{
		name = "wet-concrete",
		ingredients = {
			{"stone",6},
			{type="fluid",name="water",amount=5}
		},
		result = "concrete",
		result_count = 4,
		energy_required = 3,
		category = "refining",
		icons = {"water"},
		prerequisites = {"hub-tier3-coal-power"}
	},
	{
		name = "pure-copper-ingot",
		ingredients = {
			{"copper-ore",6},
			{type="fluid",name="water",amount=4}
		},
		result = "copper-ingot",
		result_count = 15,
		energy_required = 24,
		category = "refining",
		icons = {"water"},
		prerequisites = {"hub-tier3-coal-power"}
	},
	{
		name = "steamed-copper-sheet",
		ingredients = {
			{"copper-ingot",3},
			{type="fluid",name="water",amount=3}
		},
		result = "copper-sheet",
		result_count = 3,
		energy_required = 8,
		category = "refining",
		icons = {"water"},
		prerequisites = {"hub-tier3-coal-power"}
	},
	{
		name = "pure-iron-ingot",
		ingredients = {
			{"iron-ore",7},
			{type="fluid",name="water",amount=4}
		},
		result = "iron-ingot",
		result_count = 13,
		energy_required = 12,
		category = "refining",
		icons = {"water"},
		prerequisites = {"hub-tier3-coal-power"}
	},
	{
		name = "pure-caterium-ingot",
		ingredients = {
			{"caterium-ore",2},
			{type="fluid",name="water",amount=2}
		},
		result = "caterium-ingot",
		result_count = 1,
		energy_required = 5,
		category = "refining",
		icons = {"water"},
		prerequisites = {"hub-tier3-coal-power","mam-caterium-caterium"}
	},
	{
		name = "pure-quartz-crystal",
		ingredients = {
			{"raw-quartz",9},
			{type="fluid",name="water",amount=5}
		},
		result = "quartz-crystal",
		result_count = 7,
		energy_required = 8,
		category = "refining",
		icons = {"water"},
		prerequisites = {"hub-tier3-coal-power","mam-quartz-quartz-crystals"}
	},
	{
		name = "compacted-coal",
		ingredients = {
			{"coal",5},
			{"sulfur",5}
		},
		result = "compacted-coal",
		result_count = 5,
		energy_required = 12,
		category = "assembling",
		icons = {},
		prerequisites = {"hub-tier3-coal-power","mam-sulfur-sulfur"}
	},
	{
		name = "encased-industrial-pipe",
		ingredients = {
			{"steel-pipe",7},
			{"concrete",5}
		},
		result = "encased-industrial-beam",
		result_count = 1,
		energy_required = 15,
		category = "assembling",
		icons = {"steel-pipe"},
		prerequisites = {"hub-tier4-advanced-steel-production"}
	},
	{
		name = "high-speed-wiring",
		ingredients = {
			{"stator",2},
			{"wire",40},
			{"high-speed-connector",1}
		},
		result = "automated-wiring",
		result_count = 4,
		energy_required = 32,
		category = "manufacturing",
		icons = {"high-speed-connector"},
		prerequisites = {"hub-tier4-advanced-steel-production","mam-caterium-ai-limiter"}
	},
	{
		name = "quickwire-stator",
		ingredients = {
			{"steel-pipe",4},
			{"quickwire",15}
		},
		result = "stator",
		result_count = 2,
		energy_required = 15,
		category = "assembling",
		icons = {"quickwire"},
		prerequisites = {"hub-tier4-advanced-steel-production","mam-caterium-caterium-ingots"}
	},
	{
		name = "rigour-motor",
		ingredients = {
			{"rotor",3},
			{"stator",3},
			{"crystal-oscillator",1}
		},
		result = "motor",
		result_count = 6,
		energy_required = 48,
		category = "manufacturing",
		icons = {"crystal-oscillator"},
		prerequisites = {"hub-tier4-advanced-steel-production","mam-quartz-quartz-crystals"}
	},
	{
		name = "coated-iron-canister",
		ingredients = {
			{"iron-plate",2},
			{"copper-sheet",1}
		},
		result = "empty-canister",
		result_count = 4,
		energy_required = 4,
		category = "assembling",
		icons = {"iron-plate"},
		prerequisites = {"hub-tier5-alternative-fluid-transport"}
	},
	{
		name = "steel-canister",
		ingredients = {
			{"steel-ingot",3}
		},
		result = "empty-canister",
		result_count = 2,
		energy_required = 3,
		category = "constructing",
		icons = {"steel-ingot"},
		prerequisites = {"hub-tier5-alternative-fluid-transport"}
	},
	{
		name = "heavy-encased-frame",
		ingredients = {
			{"modular-frame",8},
			{"encased-industrial-beam",10},
			{"steel-pipe",36},
			{"concrete",22}
		},
		result = "heavy-modular-frame",
		result_count = 3,
		energy_required = 64,
		category = "manufacturing",
		icons = {"concrete"},
		prerequisites = {"hub-tier5-industrial-manufacturing"}
	},
	{
		name = "heavy-flexible-frame",
		ingredients = {
			{"modular-frame",5},
			{"encased-industrial-beam",3},
			{"rubber",20},
			{"screw",104}
		},
		result = "heavy-modular-frame",
		result_count = 1,
		energy_required = 16,
		category = "manufacturing",
		icons = {"rubber"},
		prerequisites = {"hub-tier5-industrial-manufacturing"}
	},
	{
		name = "automated-miner",
		ingredients = {
			{"motor",1},
			{"steel-pipe",4},
			{"iron-rod",4},
			{"iron-plate",2}
		},
		result = "portable-miner",
		energy_required = 60,
		category = "manufacturing",
		icons = {"motor"},
		prerequisites = {"hub-tier5-industrial-manufacturing"}
	},
	{
		name = "caterium-computer",
		ingredients = {
			{"circuit-board",7},
			{"quickwire",28},
			{"rubber",12}
		},
		result = "computer",
		result_count = 1,
		energy_required = 16,
		category = "manufacturing",
		icons = {"quickwire"},
		prerequisites = {"hub-tier5-industrial-manufacturing","mam-caterium-caterium-ingots"}
	},
	{
		name = "crystal-computer",
		ingredients = {
			{"circuit-board",8},
			{"crystal-oscillator",3}
		},
		result = "computer",
		result_count = 3,
		energy_required = 64,
		category = "assembling",
		icons = {"crystal-oscillator"},
		prerequisites = {"hub-tier5-industrial-manufacturing","mam-quartz-quartz-crystals"}
	},
	{
		name = "coated-cable",
		ingredients = {
			{"wire",5},
			{type="fluid",name="heavy-oil",amount=2}
		},
		result = "copper-cable",
		result_count = 9,
		energy_required = 8,
		category = "refining",
		icons = {"heavy-oil-residue"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "insulated-cable",
		ingredients = {
			{"wire",9},
			{"rubber",6}
		},
		result = "copper-cable",
		result_count = 20,
		energy_required = 12,
		category = "assembling",
		icons = {"rubber"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "electrode-circuit-board",
		ingredients = {
			{"rubber",6},
			{"petroleum-coke",9}
		},
		result = "circuit-board",
		result_count = 1,
		energy_required = 12,
		category = "assembling",
		icons = {"petroleum-coke"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "rubber-concrete",
		ingredients = {
			{"stone",10},
			{"rubber",2}
		},
		result = "concrete",
		result_count = 9,
		energy_required = 12,
		category = "assembling",
		icons = {"rubber"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "heavy-oil-residue",
		ingredients = {
			{type="fluid",name="crude-oil",amount=3}
		},
		results = {
			{type="fluid",name="heavy-oil",amount=4},
			{"polymer-resin",2}
		},
		main_product = "heavy-oil",
		subgroup = "fluid-recipe",
		energy_required = 6,
		category = "refining",
		icons = {},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "coated-iron-plate",
		ingredients = {
			{"iron-ingot",10},
			{"plastic",2}
		},
		result = "iron-plate",
		result_count = 15,
		energy_required = 12,
		category = "assembling",
		icons = {"plastic"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "steel-coated-plate",
		ingredients = {
			{"steel-ingot",2},
			{"plastic",2}
		},
		result = "iron-plate",
		result_count = 18,
		energy_required = 24,
		category = "assembling",
		icons = {"steel-ingot"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "recycled-plastic",
		ingredients = {
			{"rubber",6},
			{type="fluid",name="fuel",amount=6}
		},
		result = "plastic",
		result_count = 12,
		energy_required = 12,
		category = "refining",
		icons = {"rubber"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "polymer-resin",
		ingredients = {
			{type="fluid",name="crude-oil",amount=6}
		},
		results = {
			{"polymer-resin",13},
			{type="fluid",name="heavy-oil",amount=2}
		},
		main_product = "polymer-resin",
		energy_required = 6,
		category = "refining",
		icons = {},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "adhered-iron-plate",
		ingredients = {
			{"iron-plate",3},
			{"rubber",1}
		},
		result = "reinforced-iron-plate",
		result_count = 1,
		energy_required = 16,
		category = "assembling",
		icons = {"rubber"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "recycled-rubber",
		ingredients = {
			{"plastic",6},
			{type="fluid",name="fuel",amount=6}
		},
		result = "rubber",
		result_count = 12,
		energy_required = 12,
		category = "refining",
		icons = {"plastic"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "plastic-smart-plating",
		ingredients = {
			{"reinforced-iron-plate",1},
			{"rotor",1},
			{"plastic",3}
		},
		result = "smart-plating",
		result_count = 2,
		energy_required = 24,
		category = "manufacturing",
		icons = {"plastic"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "coke-steel-ingot",
		ingredients = {
			{"iron-ore",15},
			{"petroleum-coke",15}
		},
		result = "steel-ingot",
		result_count = 20,
		energy_required = 12,
		category = "foundry",
		icons = {"petroleum-coke"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "flexible-framework",
		ingredients = {
			{"modular-frame",1},
			{"steel-beam",6},
			{"rubber",8}
		},
		result = "versatile-framework",
		result_count = 2,
		energy_required = 16,
		category = "manufacturing",
		icons = {"rubber"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "quickwire-cable",
		ingredients = {
			{"quickwire",3},
			{"rubber",2}
		},
		result = "copper-cable",
		result_count = 11,
		energy_required = 24,
		category = "assembling",
		icons = {"quickwire"},
		prerequisites = {"hub-tier5-oil-processing","mam-caterium-caterium-ingots"}
	},
	{
		name = "caterium-circuit-board",
		ingredients = {
			{"plastic",10},
			{"quickwire",30}
		},
		result = "circuit-board",
		result_count = 7,
		energy_required = 48,
		category = "assembling",
		icons = {"quickwire"},
		prerequisites = {"hub-tier5-oil-processing","mam-caterium-caterium-ingots"}
	},
	{
		name = "silicon-high-speed-connector",
		ingredients = {
			{"quickwire",60},
			{"silica",25},
			{"circuit-board",2}
		},
		result = "high-speed-connector",
		result_count = 2,
		energy_required = 40,
		category = "manufacturing",
		icons = {"silica"},
		prerequisites = {"hub-tier5-oil-processing","mam-caterium-high-speed-connector","mam-quartz-quartz"}
	},
	{
		name = "insulated-crystal-oscillator",
		ingredients = {
			{"quartz-crystal",10},
			{"rubber",7},
			{"ai-limiter",1}
		},
		result = "crystal-oscillator",
		result_count = 1,
		energy_required = 32,
		category = "manufacturing",
		icons = {"rubber"},
		prerequisites = {"hub-tier5-oil-processing","mam-quartz-crystal-oscillator","mam-caterium-caterium-electronics"}
	},
	{
		name = "silicon-circuit-board",
		ingredients = {
			{"copper-sheet",11},
			{"silica",11}
		},
		result = "circuit-board",
		result_count = 5,
		energy_required = 24,
		category = "assembling",
		icons = {"silica"},
		prerequisites = {"hub-tier5-oil-processing","mam-quartz-quartz"}
	},
	{
		name = "diluted-packaged-fuel",
		ingredients = {
			{type="fluid",name="heavy-oil",amount=1},
			{"packaged-water",2}
		},
		result = "packaged-fuel",
		result_count = 2,
		energy_required = 2,
		category = "refining",
		icons = {"packaged-water"},
		prerequisites = {"hub-tier5-oil-processing"}
	},
	{
		name = "turbo-heavy-fuel",
		ingredients = {
			{type="fluid",name="heavy-oil",amount=4},
			{"compacted-coal",4}
		},
		results = {{type="fluid",name="turbofuel",amount=4}},
		main_product = "turbofuel",
		subgroup = "fluid-recipe",
		energy_required = 8,
		category = "refining",
		icons = {"heavy-oil-residue"},
		prerequisites = {"hub-tier5-oil-processing","alt-compacted-coal"}
	},
	{
		name = "classic-battery",
		ingredients = {
			{"sulfur",6},
			{"alclad-aluminium-sheet",7},
			{"plastic",8},
			{"wire",12}
		},
		result = "battery",
		result_count = 4,
		energy_required = 8,
		category = "manufacturing",
		icons = {"plastic"},
		prerequisites = {"hub-tier7-aeronautical-engineering"}
	},
	{
		name = "electric-motor",
		ingredients = {
			{"electromagnetic-control-rod",1},
			{"rotor",2}
		},
		result = "motor",
		result_count = 2,
		energy_required = 16,
		category = "assembling",
		icons = {"electromagnetic-control-rod"},
		prerequisites = {"hub-tier7-aeronautical-engineering"}
	},
	{
		name = "oc-supercomputer",
		ingredients = {
			{"radio-control-unit",3},
			{"cooling-system",3}
		},
		result = "supercomputer",
		result_count = 1,
		energy_required = 20,
		category = "assembling",
		icons = {"cooling-system"},
		prerequisites = {"hub-tier7-aeronautical-engineering","hub-tier8-advanced-aluminium-production"}
	},
	{
		name = "super-state-computer",
		ingredients = {
			{"computer",3},
			{"electromagnetic-control-rod",2},
			{"battery",20},
			{"wire",45}
		},
		result = "supercomputer",
		result_count = 2,
		energy_required = 50,
		category = "manufacturing",
		icons = {"electromagnetic-control-rod"},
		prerequisites = {"hub-tier7-aeronautical-engineering","hub-tier8-nuclear-power"}
	},
	{
		name = "sloppy-alumina",
		ingredients = {
			{"bauxite",10},
			{type="fluid",name="water",amount=10}
		},
		results = {{type="fluid",name="alumina-solution",amount=12}},
		main_product = "alumina-solution",
		subgroup = "fluid-recipe",
		energy_required = 3,
		category = "refining",
		icons = {"water"},
		prerequisites = {"hub-tier7-bauxite-refinement"}
	},
	{
		name = "alclad-casing",
		ingredients = {
			{"aluminium-ingot",20},
			{"copper-ingot",10}
		},
		result = "aluminium-casing",
		result_count = 15,
		energy_required = 8,
		category = "assembling",
		icons = {"copper-ingot"},
		prerequisites = {"hub-tier7-bauxite-refinement"}
	},
	{
		name = "pure-aluminium-ingot",
		ingredients = {
			{"aluminium-scrap",2}
		},
		result = "aluminium-ingot",
		result_count = 1,
		energy_required = 2,
		category = "smelter",
		icons = {},
		prerequisites = {"hub-tier7-bauxite-refinement"}
	},
	{
		name = "electrode-aluminium-scrap",
		ingredients = {
			{type="fluid",name="alumina-solution",amount=12},
			{"petroleum-coke",4}
		},
		results = {
			{"aluminium-scrap",20},
			{type="fluid",name="water",amount=7}
		},
		main_product = "aluminium-scrap",
		energy_required = 4,
		category = "refining",
		icons = {"petroleum-coke"},
		prerequisites = {"hub-tier7-bauxite-refinement"}
	},
	{
		name = "diluted-fuel",
		ingredients = {
			{type="fluid",name="heavy-oil",amount=5},
			{type="fluid",name="water",amount=10}
		},
		results = {{type="fluid",name="fuel",amount=10}},
		main_product = "fuel",
		subgroup = "fluid-recipe",
		energy_required = 6,
		category = "blending",
		icons = {"water"},
		prerequisites = {"hub-tier7-bauxite-refinement"}
	},
	{
		name = "radio-control-system",
		ingredients = {
			{"crystal-oscillator",1},
			{"circuit-board",10},
			{"aluminium-casing",60},
			{"rubber",30}
		},
		result = "radio-control-unit",
		result_count = 3,
		energy_required = 40,
		category = "manufacturing",
		icons = {"crystal-oscillator"},
		prerequisites = {"hub-tier7-bauxite-refinement"}
	},
	{
		name = "instant-scrap",
		ingredients = {
			{"bauxite",15},
			{"coal",10},
			{type="fluid",name="sulfuric-acid",amount=5},
			{type="fluid",name="water",amount=6}
		},
		results = {
			{"aluminium-scrap",30},
			{type="fluid",name="water",amount=5}
		},
		main_product = "aluminium-scrap",
		energy_required = 6,
		category = "blending",
		icons = {"bauxite"},
		prerequisites = {"hub-tier7-bauxite-refinement","hub-tier7-aeronautical-engineering"}
	},
	{
		name = "radio-connection-unit",
		ingredients = {
			{"heat-sink",4},
			{"high-speed-connector",2},
			{"quartz-crystal",12}
		},
		result = "radio-control-unit",
		result_count = 1,
		energy_required = 16,
		category = "manufacturing",
		icons = {"high-speed-connector"},
		prerequisites = {"hub-tier7-bauxite-refinement","hub-tier8-advanced-aluminium-production"}
	},
	{
		name = "cooling-device",
		ingredients = {
			{"heat-sink",5},
			{"motor",1},
			{type="fluid",name="nitrogen-gas",amount=24}
		},
		result = "cooling-system",
		result_count = 2,
		energy_required = 32,
		category = "blending",
		icons = {"motor"},
		prerequisites = {"hub-tier8-advanced-aluminium-production"}
	},
	{
		name = "heat-exchanger",
		ingredients = {
			{"aluminium-casing",3},
			{"rubber",3}
		},
		result = "heat-sink",
		result_count = 1,
		energy_required = 6,
		category = "assembling",
		icons = {"rubber"},
		prerequisites = {"hub-tier8-advanced-aluminium-production"}
	},
	{
		name = "heat-fused-frame",
		ingredients = {
			{"heavy-modular-frame",1},
			{"aluminium-ingot",50},
			{type="fluid",name="nitric-acid",amount=8},
			{type="fluid",name="fuel",amount=10}
		},
		result = "fused-modular-frame",
		result_count = 1,
		energy_required = 20,
		category = "blending",
		icons = {"fuel"},
		prerequisites = {"hub-tier8-advanced-aluminium-production","hub-tier8-particle-enrichment"}
	},
	{
		name = "turbo-electric-motor",
		ingredients = {
			{"motor",7},
			{"radio-control-unit",9},
			{"electromagnetic-control-rod",5},
			{"rotor",7}
		},
		result = "turbo-motor",
		result_count = 3,
		energy_required = 64,
		category = "manufacturing",
		icons = {"electromagnetic-control-rod"},
		prerequisites = {"hub-tier8-leading-edge-production","hub-tier8-nuclear-power"}
	},
	{
		name = "electromagnetic-connection-rod",
		ingredients = {
			{"stator",10},
			{"high-speed-connector",5}
		},
		result = "electromagnetic-control-rod",
		result_count = 10,
		energy_required = 60,
		category = "assembling",
		icons = {"high-speed-connector"},
		prerequisites = {"hub-tier8-nuclear-power","mam-caterium-ai-limiter"}
	},
	{
		name = "infused-uranium-cell",
		ingredients = {
			{"uranium-ore",5},
			{"silica",3},
			{"sulfur",5},
			{"quickwire",15}
		},
		result = "encased-uranium-cell",
		result_count = 4,
		energy_required = 12,
		category = "manufacturing",
		icons = {"sulfur"},
		prerequisites = {"hub-tier8-nuclear-power","mam-caterium-caterium-ingots","mam-quartz-quartz","mam-sulfur-sulfur"}
	},
	{
		name = "uranium-fuel-unit",
		ingredients = {
			{"encased-uranium-cell",100},
			{"electromagnetic-control-rod",10},
			{"crystal-oscillator",3},
			{"map-marker",6}
		},
		result = "uranium-fuel-rod",
		result_count = 3,
		energy_required = 300,
		category = "manufacturing",
		icons = {"crystal-oscillator"},
		prerequisites = {"hub-tier8-nuclear-power","mam-quartz-quartz-crystals"}
	},
	{
		name = "instant-plutonium-cell",
		ingredients = {
			{"non-fissile-uranium",150},
			{"aluminium-casing",20}
		},
		result = "encased-plutonium-cell",
		result_count = 20,
		energy_required = 120,
		category = "accelerating",
		icons = {"non-fissile-uranium"},
		prerequisites = {"hub-tier8-particle-enrichment"}
	},
	{
		name = "fertile-uranium",
		ingredients = {
			{"uranium-ore",5},
			{"uranium-waste",5},
			{type="fluid",name="nitric-acid",amount=3},
			{type="fluid",name="sulfuric-acid",amount=5}
		},
		results = {
			{"non-fissile-uranium",20},
			{type="fluid",name="water",amount=8}
		},
		main_product = "non-fissile-uranium",
		energy_required = 12,
		category = "blending",
		icons = {"uranium-ore"},
		prerequisites = {"hub-tier8-particle-enrichment"}
	},
	{
		name = "plutonium-fuel-unit",
		ingredients = {
			{"encased-plutonium-cell",20},
			{"pressure-conversion-cube",1}
		},
		result = "plutonium-fuel-rod",
		result_count = 1,
		energy_required = 120,
		category = "assembling",
		icons = {"pressure-conversion-cube"},
		prerequisites = {"hub-tier8-particle-enrichment"}
	},
	{
		name = "turbo-pressure-motor",
		ingredients = {
			{"motor",4},
			{"pressure-conversion-cube",1},
			{"packaged-nitrogen-gas",24},
			{"stator",8}
		},
		result = "turbo-motor",
		result_count = 2,
		energy_required = 32,
		category = "manufacturing",
		icons = {"pressure-conversion-cube"},
		prerequisites = {"hub-tier8-particle-enrichment"}
	},
	{
		name = "expanded-pocket-dimension",
		prerequisites = {}
	},
	{
		name = "inflated-pocket-dimension",
		prerequisites = {"hub-tier5-industrial-manufacturing"}
	}
}

return recipes
