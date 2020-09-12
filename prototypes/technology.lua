local lab = assert(data.raw.lab.omnilab, "Technology must be loaded AFTER the Omnilab")

local function addTech(name, icon, category, subgroup, order, time, prerequisites, ingredients, effects)
	table.insert(lab.inputs, name)
	data:extend({
		{
			type = "tool",
			name = name,
			subgroup = subgroup,
			order = order,
			icon = "__Satisfactorio__/graphics/icons/"..icon..".png",
			icon_size = 64,
			stack_size = 1,
			durability = 1,
			flags = {"hidden"}
		},
		{
			type = "recipe",
			name = name,
			ingredients = ingredients,
			result = name,
			energy_required = time,
			category = category,
			allow_intermediates = false,
			allow_as_intermediate = false,
			hide_from_stats = true,
			hide_from_player_crafting = true,
			enabled = false
		},
		{
			type = "technology",
			name = name,
			order = order,
			icon = "__Satisfactorio__/graphics/icons/"..icon..".png",
			icon_size = 64,
			prerequisites = prerequisites,
			unit = {
				count = 1,
				time = time,
				ingredients = {{name,1}},
			},
			effects = effects
		}
	})
end

data:extend({
	{
		type = "technology",
		name = "the-hub",
		order = "a",
		icon = "__Satisfactorio__/graphics/icons/the-hub.png",
		icon_size = 64,
		unit = {
			count = 1,
			time = 1,
			ingredients = {{"hub-parts",1}},
		},
		effects = {}
	},
	{
		icon = "__Satisfactorio__/graphics/icons/hub-parts.png",
		icon_size = 64,
		name = "hub-parts",
		order = "a[hub-parts]",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	}
})


addTech("hub-tier0-hub-upgrade-1", "portable-miner", "hub-progressing", "hub-tier0", "a-0-1", 1, {"the-hub"}, {
	{"iron-stick",10}
}, {
	{type="unlock-recipe",recipe="equipment-workshop"},
	{type="unlock-recipe",recipe="portable-miner"},
	{type="character-inventory-slots-bonus",modifier=3},
	{type="nothing",effect_description={"technology-effect.add-storage-to-hub"}}
})
data.raw.recipe['hub-tier0-hub-upgrade-1'].enabled = true
addTech("hub-tier0-hub-upgrade-2", "copper-ingot", "hub-progressing", "hub-tier0", "a-0-2", 1, {"hub-tier0-hub-upgrade-1"}, {
	{"iron-stick",20},
	{"iron-plate",10}
}, {
	{type="unlock-recipe",recipe="smelter"},
	{type="unlock-recipe",recipe="copper-ingot"},
	{type="unlock-recipe",recipe="wire"},
	{type="unlock-recipe",recipe="copper-cable"},
	{type="unlock-recipe",recipe="scanner-copper-ore"},
	{type="nothing",effect_description={"technology-effect.add-biomass-burner-to-hub"}}
})
addTech("hub-tier0-hub-upgrade-3", "concrete", "hub-progressing", "hub-tier0", "a-0-3", 1, {"hub-tier0-hub-upgrade-2"}, {
	{"iron-plate",20},
	{"iron-stick",20},
	{"wire",20}
}, {
	{type="unlock-recipe",recipe="constructor"},
	{type="unlock-recipe",recipe="small-electric-pole"},
	{type="unlock-recipe",recipe="concrete"},
	{type="unlock-recipe",recipe="screw"},
	{type="unlock-recipe",recipe="reinforced-iron-plate"},
	{type="unlock-recipe",recipe="scanner-stone"}
})
addTech("hub-tier0-hub-upgrade-4", "conveyor-belt-mk-1", "hub-progressing", "hub-tier0", "a-0-4", 1, {"hub-tier0-hub-upgrade-3"}, {
	{"iron-plate",75},
	{"copper-cable",20},
	{"concrete",10}
}, {
	{type="unlock-recipe",recipe="transport-belt"},
	{type="character-inventory-slots-bonus",modifier=3}
})
addTech("hub-tier0-hub-upgrade-5", "miner-mk-1", "hub-progressing", "hub-tier0", "a-0-5", 1, {"hub-tier0-hub-upgrade-4"}, {
	{"iron-stick",75},
	{"copper-cable",50},
	{"concrete",20}
}, {
	{type="unlock-recipe",recipe="miner-mk-1"},
	{type="unlock-recipe",recipe="iron-chest"},
	{type="nothing",effect_description={"technology-effect.add-biomass-burner-to-hub"}}
})
addTech("hub-tier0-hub-upgrade-6", "biomass-burner", "hub-progressing", "hub-tier0", "a-0-6", 1, {"hub-tier0-hub-upgrade-5"}, {
	{"iron-stick",100},
	{"iron-plate",100},
	{"wire",100},
	{"concrete",50}
}, {
	--{type="unlock-recipe",recipe="space-elevator"},
	{type="unlock-recipe",recipe="biomass-burner"},
	{type="unlock-recipe",recipe="biomass-from-leaves"},
	{type="unlock-recipe",recipe="biomass-from-wood"},
	{type="nothing",effect_description={"technology-effect.add-ficsit-freighter-to-hub"}}
})

addTech("hub-tier1-base-building", "foundation", "hub-progressing", "hub-tier1", "a-1-1", 120, {"hub-tier0-hub-upgrade-6"}, {
	{"concrete",200},
	{"iron-plate",100},
	{"iron-stick",100}
}, {
	{type="unlock-recipe",recipe="lookout-tower"},
	{type="unlock-recipe",recipe="foundation"},
	{type="unlock-recipe",recipe="stone-wall"}
})
addTech("hub-tier1-logistics", "conveyor-splitter", "hub-progressing", "hub-tier1", "a-1-2", 240, {"hub-tier0-hub-upgrade-6"}, {
	{"iron-plate",150},
	{"iron-stick",150},
	{"wire",300}
}, {
	{type="unlock-recipe",recipe="conveyor-splitter"},
	{type="unlock-recipe",recipe="conveyor-merger"},
	{type="unlock-recipe",recipe="underground-belt"}
})
addTech("hub-tier1-field-research", "mam", "hub-progressing", "hub-tier1", "a-1-3", 180, {"hub-tier0-hub-upgrade-6"}, {
	{"wire",300},
	{"screw",300},
	{"iron-plate",100}
}, {
	{type="unlock-recipe",recipe="mam"},
	{type="unlock-recipe",recipe="wooden-chest"},
	{type="unlock-recipe",recipe="map-marker"},
	{type="character-inventory-slots-bonus",modifier=5}
})

