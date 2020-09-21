local name = "empty-canister"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "fill-barrel",
		order = "a["..name.."]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = name.."-manual",
		ingredients = {{"plastic-bar",2}},
		result = name,
		result_count = 4,
		energy_required = 2/4,
		category = "craft-bench",
		enabled = false
	},
	{
		type = "recipe",
		name = name,
		ingredients = {{"plastic-bar",2}},
		result = name,
		result_count = 4,
		energy_required = 4,
		category = "constructing",
		hide_from_player_crafting = true,
		enabled = false
	},
	-- water
	{
		type = "item",
		name = "packaged-water",
		icon = "__Satisfactorio__/graphics/icons/packaged-water.png",
		icon_size = 64,
		subgroup = "fill-barrel",
		order = "b["..name.."]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = "packaged-water",
		ingredients = {{"empty-canister",2}, {type="fluid",name="water",amount=2}},
		result = "packaged-water",
		result_count = 2,
		energy_required = 2,
		category = "refining",
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-water",
		ingredients = {{"packaged-water",2}},
		results = {{"empty-canister",2}, {type="fluid",name="water",amount=2}},
		main_product = "water",
		energy_required = 1,
		category = "refining",
		hide_from_player_crafting = true,
		enabled = false
	},
	-- crude oil
	{
		type = "item",
		name = "packaged-oil",
		icon = "__Satisfactorio__/graphics/icons/packaged-oil.png",
		icon_size = 64,
		subgroup = "fill-barrel",
		order = "c["..name.."]",
		stack_size = 100,
		fuel_category = "packaged-alt-fuel",
		fuel_value = "320MJ",
	},
	{
		type = "recipe",
		name = "packaged-oil",
		ingredients = {{"empty-canister",2}, {type="fluid",name="crude-oil",amount=2}},
		result = "packaged-oil",
		result_count = 2,
		energy_required = 4,
		category = "refining",
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-oil",
		ingredients = {{"packaged-oil",2}},
		results = {{"empty-canister",2}, {type="fluid",name="crude-oil",amount=2}},
		main_product = "crude-oil",
		energy_required = 2,
		category = "refining",
		subgroup = "empty-barrel",
		hide_from_player_crafting = true,
		enabled = false
	},
	-- heavy oil residue
	{
		type = "item",
		name = "packaged-heavy-oil",
		icon = "__Satisfactorio__/graphics/icons/packaged-heavy-oil-residue.png",
		icon_size = 64,
		subgroup = "fill-barrel",
		order = "d["..name.."]",
		stack_size = 100,
		fuel_category = "packaged-alt-fuel",
		fuel_value = "400MJ",
	},
	{
		type = "recipe",
		name = "packaged-heavy-oil",
		ingredients = {{"empty-canister",2}, {type="fluid",name="heavy-oil",amount=2}},
		result = "packaged-heavy-oil",
		result_count = 2,
		energy_required = 4,
		category = "refining",
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-heavy-oil",
		ingredients = {{"packaged-heavy-oil",2}},
		results = {{"empty-canister",2}, {type="fluid",name="heavy-oil",amount=2}},
		main_product = "heavy-oil",
		energy_required = 6,
		category = "refining",
		subgroup = "empty-barrel",
		hide_from_player_crafting = true,
		enabled = false
	},
	-- fuel
	{
		type = "item",
		name = "packaged-fuel",
		icon = "__Satisfactorio__/graphics/icons/packaged-fuel.png",
		icon_size = 64,
		subgroup = "fill-barrel",
		order = "e["..name.."]",
		stack_size = 100,
		fuel_category = "packaged-fuel",
		fuel_value = "600MJ",
	},
	{
		type = "recipe",
		name = "packaged-fuel",
		ingredients = {{"empty-canister",2}, {type="fluid",name="fuel",amount=2}},
		result = "packaged-fuel",
		result_count = 2,
		energy_required = 3,
		category = "refining",
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-fuel",
		ingredients = {{"packaged-fuel",2}},
		results = {{"empty-canister",2}, {type="fluid",name="fuel",amount=2}},
		main_product = "fuel",
		energy_required = 2,
		category = "refining",
		subgroup = "empty-barrel",
		hide_from_player_crafting = true,
		enabled = false
	},
	-- liquid biofuel
	{
		type = "item",
		name = "packaged-liquid-biofuel",
		icon = "__Satisfactorio__/graphics/icons/packaged-liquid-biofuel.png",
		icon_size = 64,
		subgroup = "fill-barrel",
		order = "f["..name.."]",
		stack_size = 100,
		fuel_category = "chemical",
		fuel_value = "750MJ",
	},
	{
		type = "recipe",
		name = "packaged-liquid-biofuel",
		ingredients = {{"empty-canister",2}, {type="fluid",name="liquid-biofuel",amount=2}},
		result = "packaged-liquid-biofuel",
		result_count = 2,
		energy_required = 3,
		category = "refining",
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-liquid-biofuel",
		ingredients = {{"packaged-liquid-biofuel",2}},
		results = {{"empty-canister",2}, {type="fluid",name="liquid-biofuel",amount=2}},
		main_product = "liquid-biofuel",
		energy_required = 2,
		category = "refining",
		subgroup = "empty-barrel",
		hide_from_player_crafting = true,
		enabled = false
	},
	-- turbofuel
	{
		type = "item",
		name = "packaged-turbofuel",
		icon = "__Satisfactorio__/graphics/icons/packaged-turbofuel.png",
		icon_size = 64,
		subgroup = "fill-barrel",
		order = "g["..name.."]",
		stack_size = 100,
		fuel_category = "packaged-alt-fuel",
		fuel_value = "2GJ",
	},
	{
		type = "recipe",
		name = "packaged-turbofuel",
		ingredients = {{"empty-canister",2}, {type="fluid",name="turbofuel",amount=2}},
		result = "packaged-turbofuel",
		result_count = 2,
		energy_required = 6,
		category = "refining",
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-turbofuel",
		ingredients = {{"packaged-turbofuel",2}},
		results = {{"empty-canister",2}, {type="fluid",name="turbofuel",amount=2}},
		main_product = "turbofuel",
		energy_required = 6,
		category = "refining",
		subgroup = "empty-barrel",
		hide_from_player_crafting = true,
		enabled = false
	}
})
