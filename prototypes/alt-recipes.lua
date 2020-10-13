-- Hard Drive item used for research
data:extend({
	{
		type = "tool",
		name = "hard-drive",
		subgroup = "special",
		order = "z[hard-drive]",
		stack_size = 100,
		icon = "__Satisfactorio__/graphics/icons/hard-drive.png",
		icon_size = 64,
		infinite = true
	}
})

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
		icons = {"iron-ore"}
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
		icons = {"compacted-coal"}
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
		icons = {"caterium-ingot"}
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
		icons = {"copper-ingot"}
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
		icons = {"copper-ingot","caterium-ingot"}
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
		icons = {"water"}
	},
	{
		name = "radio-control-system",
		ingredients = {
			{"heat-sink",10},
			{"supercomputer",1},
			{"quartz-crystal",30}
		},
		result = "radio-control-unit",
		result_count = 3,
		energy_required = 48,
		category = "manufacturing",
		icons = {"supercomputer"}
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
		icons = {"limestone"}
	},
	--[[{
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
		icons = {"crystal-oscillator"}
	},]]
	{
		name = "casted-screw",
		ingredients = {
			{"iron-ingot",5}
		},
		result = "screw",
		result_count = 20,
		energy_required = 24,
		category = "constructing",
		icons = {"iron-ingot"}
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
		icons = {"iron-ingot"}
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
		icons = {"copper-ore"}
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
		icons = {"screw"}
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
		icons = {"wire"}
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
		icons = {"screw"}
	},
	{
		name = "copper-rotor",
		ingredients = {
			{"copper-plate",6},
			{"screw",52}
		},
		result = "rotor",
		result_count = 3,
		energy_required = 16,
		category = "assembling",
		icons = {"copper-sheet"}
	},
	{
		name = "steel-rod",
		ingredients = {
			{"steel-ingot",1}
		},
		result = "iron-stick",
		result_count = 4,
		energy_required = 5,
		category = "constructing",
		icons = {"steel-ingot"}
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
		icons = {"steel-pipe"}
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
		icons = {"steel-pipe"}
	},
	{
		name = "steel-screw",
		ingredients = {
			{"steel-plate",1}
		},
		result = "screw",
		result_count = 52,
		energy_required = 12,
		category = "constructing",
		icons = {"steel-beam"}
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
		icons = {"iron-ingot"}
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
		icons = {"compacted-coal"}
	},
	{
		name = "signal-beacon",
		ingredients = {
			{"steel-plate",4},
			{"steel-pipe",16},
			{"crystal-oscillator",1}
		},
		result = "map-marker",
		result_count = 20,
		energy_required = 120,
		category = "manufacturing",
		icons = {"crystal-oscillator"}
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
		icons = {"biomass"}
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
		icons = {"wood"}
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
		icons = {"water"}
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
		icons = {"water"}
	},
	{
		name = "steamed-copper-sheet",
		ingredients = {
			{"copper-ingot",3},
			{type="fluid",name="water",amount=3}
		},
		result = "copper-plate",
		result_count = 3,
		energy_required = 8,
		category = "refining",
		icons = {"water"}
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
		icons = {"water"}
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
		icons = {"water"}
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
		icons = {"water"}
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
		icons = {}
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
		icons = {"steel-pipe"}
	},
	{
		name = "high-speed-wiring",
		ingredients = {
			{"stator",2},
			{"wire",40},
			{"advanced-circuit",1}
		},
		result = "automated-wiring",
		result_count = 4,
		energy_required = 32,
		category = "manufacturing",
		icons = {"high-speed-connector"}
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
		icons = {"quickwire"}
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
		icons = {"crystal-oscillator"}
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
		icons = {"concrete"}
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
		icons = {"rubber"}
	},
	{
		name = "caterium-computer",
		ingredients = {
			{"electronic-circuit",7},
			{"quickwire",28},
			{"rubber",12}
		},
		result = "computer",
		result_count = 1,
		energy_required = 16,
		category = "manufacturing",
		icons = {"quickwire"}
	},
	{
		name = "crystal-computer",
		ingredients = {
			{"electronic-circuit",8},
			{"crystal-oscillator",3}
		},
		result = "computer",
		result_count = 3,
		energy_required = 64,
		category = "assembling",
		icons = {"crystal-oscillator"}
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
		icons = {"heavy-oil-residue"}
	},
	{
		name = "rubber-cable",
		ingredients = {
			{"wire",9},
			{"rubber",6}
		},
		result = "copper-cable",
		result_count = 20,
		energy_required = 12,
		category = "assembling",
		icons = {"rubber"}
	},
	{
		name = "electrode-circuit-board",
		ingredients = {
			{"rubber",6},
			{"petroleum-coke",9}
		},
		result = "electronic-circuit",
		result_count = 1,
		energy_required = 12,
		category = "assembling",
		icons = {"petroleum-coke"}
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
		icons = {"rubber"}
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
		energy_required = 6,
		category = "refining",
		icons = {}
	},
	{
		name = "coated-iron-plate",
		ingredients = {
			{"iron-ingot",10},
			{"plastic-bar",2}
		},
		result = "iron-plate",
		result_count = 15,
		energy_required = 12,
		category = "assembling",
		icons = {"plastic"}
	},
	{
		name = "steel-coated-plate",
		ingredients = {
			{"steel-ingot",2},
			{"plastic-bar",2}
		},
		result = "iron-plate",
		result_count = 18,
		energy_required = 24,
		category = "assembling",
		icons = {"steel-ingot"}
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
		icons = {"packaged-water"}
	},
	{
		name = "recycled-plastic",
		ingredients = {
			{"rubber",6},
			{type="fluid",name="fuel",amount=6}
		},
		result = "plastic-bar",
		result_count = 12,
		energy_required = 12,
		category = "refining",
		icons = {"rubber"}
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
		icons = {}
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
		icons = {"rubber"}
	},
	{
		name = "recycled-rubber",
		ingredients = {
			{"plastic-bar",6},
			{type="fluid",name="fuel",amount=6}
		},
		result = "rubber",
		result_count = 12,
		energy_required = 12,
		category = "refining",
		icons = {"plastic"}
	},
	{
		name = "plastic-smart-plating",
		ingredients = {
			{"reinforced-iron-plate",1},
			{"rotor",1},
			{"plastic-bar",3}
		},
		result = "smart-plating",
		result_count = 2,
		energy_required = 24,
		category = "manufacturing",
		icons = {"plastic"}
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
		icons = {"petroleum-coke"}
	},
	{
		name = "flexible-framework",
		ingredients = {
			{"modular-frame",1},
			{"steel-plate",6},
			{"rubber",8}
		},
		result = "versatile-framework",
		result_count = 2,
		energy_required = 16,
		category = "manufacturing",
		icons = {"rubber"}
	},
	{
		name = "turbofuel",
		ingredients = {
			{type="fluid",name="fuel",amount=6},
			{"compacted-coal",4}
		},
		results = {{type="fluid",name="turbofuel",amount=5}},
		main_product = "turbofuel",
		energy_required = 16,
		category = "refining",
		icons = {}
	},
	{
		name = "turbo-heavy-fuel",
		ingredients = {
			{type="fluid",name="heavy-oil",amount=4},
			{"compacted-coal",4}
		},
		results = {{type="fluid",name="turbofuel",amount=4}},
		main_product = "turbofuel",
		energy_required = 8,
		category = "refining",
		icons = {"heavy-oil-residue"}
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
		icons = {"quickwire"}
	},
	{
		name = "caterium-circuit-board",
		ingredients = {
			{"plastic-bar",10},
			{"quickwire",30}
		},
		result = "electronic-circuit",
		result_count = 7,
		energy_required = 48,
		category = "assembling",
		icons = {"quickwire"}
	},
	{
		name = "silicone-high-speed-connector",
		ingredients = {
			{"quickwire",60},
			{"silica",25},
			{"electronic-circuit",2}
		},
		result = "advanced-circuit",
		result_count = 2,
		energy_required = 40,
		category = "manufacturing",
		icons = {"silica"}
	},
	{
		name = "polyester-fabric",
		ingredients = {
			{"polymer-resin",16},
			{type="fluid",name="water",amount=10}
		},
		result = "fabric",
		result_count = 1,
		energy_required = 12,
		category = "refining",
		icons = {"polymer-resin"}
	},
	{
		name = "insulated-crystal-oscillator",
		ingredients = {
			{"quartz-crystal",10},
			{"rubber",7},
			{"processing-unit",1}
		},
		result = "crystal-oscillator",
		result_count = 1,
		energy_required = 32,
		category = "manufacturing",
		icons = {"rubber"}
	},
	{
		name = "silicone-circuit-board",
		ingredients = {
			{"copper-plate",11},
			{"silica",11}
		},
		result = "electronic-circuit",
		result_count = 5,
		energy_required = 24,
		category = "assembling",
		icons = {"silica"}
	},
	{
		name = "heat-exchanger",
		ingredients = {
			{"alclad-aluminium-sheet",20},
			{"copper-plate",30}
		},
		result = "heat-sink",
		result_count = 7,
		energy_required = 32,
		category = "assembling",
		icons = {"copper-sheet"}
	},
	{
		name = "turbo-rigour-motor",
		ingredients = {
			{"motor",7},
			{"radio-control-unit",5},
			{"processing-unit",9},
			{"stator",7}
		},
		result = "turbo-motor",
		result_count = 3,
		energy_required = 64,
		category = "manufacturing",
		icons = {"ai-limiter"}
	},
	{
		name = "pure-aluminium-ingot",
		ingredients = {
			{"aluminium-scrap",12}
		},
		result = "aluminium-ingot",
		result_count = 3,
		energy_required = 5,
		category = "smelter",
		icons = {}
	},
	{
		name = "electrode-aluminium-scrap",
		ingredients = {
			{type="fluid",name="alumina-solution",amount=3},
			{"coal",1}
		},
		results = {
			{"aluminium-scrap",5},
			{type="fluid",name="water",amount=1}
		},
		main_product = "aluminium-scrap",
		energy_required = 2,
		category = "refining",
		icons = {"coal"}
	},
	{
		name = "electromagnetic-connection-rod",
		ingredients = {
			{"stator",10},
			{"advanced-circuit",5}
		},
		result = "electromagnetic-control-rod",
		result_count = 10,
		energy_required = 60,
		category = "assembling",
		icons = {"high-speed-connector"}
	},
	{
		name = "infused-uranium-cell",
		ingredients = {
			{"uranium-pellet",40},
			{"sulfur",45},
			{"silica",45},
			{"quickwire",75}
		},
		result = "uranium-fuel-cell",
		result_count = 35,
		energy_required = 120,
		category = "manufacturing",
		icons = {"sulfur"}
	},
	{
		name = "nuclear-fuel-unit",
		ingredients = {
			{"uranium-fuel-cell",50},
			{"electromagnetic-control-rod",10},
			{"crystal-oscillator",3},
			{"map-marker",6}
		},
		result = "nuclear-fuel",
		result_count = 3,
		energy_required = 300,
		category = "manufacturing",
		icons = {"crystal-oscillator"}
	}
}
for i,r in pairs(recipes) do
	local icons = r.icons
	local product = data.raw.item[r.main_product or r.result] or data.raw.fluid[r.main_product]
	r.icons = {
		{icon = product.icon, icon_size = 64}
	}
	for i,icon in pairs(icons) do
		table.insert(r.icons, {icon = "__Satisfactorio__/graphics/icons/"..icon..".png", icon_size = 64, scale = 0.25, shift = {-8, 8-(i-1)*8}})
	end
	r.type = "recipe"
	r.localised_name = {"recipe-name."..r.name}
	r.order = product.order.."-x-alt["..i.."]"
	r.allow_decomposition = r.name == "compacted-coal" or r.name == "turbofuel"
	r.enabled = false
end
data:extend(recipes)

local alts = require("constants.alt-recipes") -- dict [base name] => {prerequisites}
for base,prereq in pairs(alts) do
	table.insert(prereq,"mam-hard-drive")
	local recipe = data.raw.recipe[base]
	local product = recipe and (data.raw.item[recipe.main_product or recipe.result] or data.raw.fluid[recipe.main_product]) or nil
	local order = "m-x-"..(product and data.raw['item-subgroup'][product.subgroup].order.."-"..product.order or "z")
	data:extend({
		{
			type = "technology",
			name = "alt-"..base,
			order = order,
			icons = {
				{icon = "__Satisfactorio__/graphics/technology/mam/hard-drive.png", icon_size = 256},
				product
					and {icon = product.icon, icon_size = 64, scale = 2, shift = {-64,64}}
					or {icon = "__Satisfactorio__/graphics/technology/mam/thumbsup.png", icon_size = 256, scale = 0.5, shift = {-64,64}}
			},
			prerequisites = prereq,
			unit = {
				count = 1,
				time = 600,
				ingredients = {{"hard-drive",1}}
			},
			effects = {
				recipe
					and {type="unlock-recipe",recipe=base}
					or {type="character-inventory-slots-bonus",modifier=5}
			},
			-- hidden = true -- avoid cluttering tech screen?
		}
	})
end
