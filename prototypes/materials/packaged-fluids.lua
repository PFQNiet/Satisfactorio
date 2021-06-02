local name = "empty-canister"
local name2 = "empty-fluid-tank"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "packed-fluid",
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
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
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
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "item",
		name = name2,
		icon = "__Satisfactorio__/graphics/icons/"..name2..".png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "a["..name2.."]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = name2.."-manual",
		ingredients = {{"aluminium-ingot",1}},
		result = name2,
		result_count = 1,
		energy_required = 2/4,
		category = "craft-bench",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = name2,
		ingredients = {{"aluminium-ingot",1}},
		result = name2,
		result_count = 1,
		energy_required = 1,
		category = "constructing",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- water
	{
		type = "item",
		name = "packaged-water",
		icon = "__Satisfactorio__/graphics/icons/packaged-water.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "b[water]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = "packaged-water",
		ingredients = {{"empty-canister",2}, {type="fluid",name="water",amount=2}},
		result = "packaged-water",
		result_count = 2,
		energy_required = 2,
		category = "packaging",
		order = "b[water]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-water",
		localised_name = {"recipe-name.unpack",{"fluid-name.water"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-water.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-water",2}},
		results = {{"empty-canister",2}, {type="fluid",name="water",amount=2}},
		main_product = "water",
		energy_required = 1,
		category = "packaging",
		order = "b[water]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- crude oil
	{
		type = "item",
		name = "packaged-crude-oil",
		icon = "__Satisfactorio__/graphics/icons/packaged-oil.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "c[crude-oil]",
		stack_size = 100,
		fuel_category = "packaged-alt-fuel",
		fuel_value = "320MJ",
	},
	{
		type = "recipe",
		name = "packaged-crude-oil",
		ingredients = {{"empty-canister",2}, {type="fluid",name="crude-oil",amount=2}},
		result = "packaged-crude-oil",
		result_count = 2,
		energy_required = 4,
		category = "packaging",
		order = "c[crude-oil]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-oil",
		localised_name = {"recipe-name.unpack",{"fluid-name.crude-oil"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/crude-oil.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-oil.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-crude-oil",2}},
		results = {{"empty-canister",2}, {type="fluid",name="crude-oil",amount=2}},
		main_product = "crude-oil",
		energy_required = 2,
		category = "packaging",
		order = "c[crude-oil]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- heavy oil residue
	{
		type = "item",
		name = "packaged-heavy-oil",
		icon = "__Satisfactorio__/graphics/icons/packaged-heavy-oil-residue.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "d[heavy-oil]",
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
		category = "packaging",
		order = "d[heavy-oil]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-heavy-oil",
		localised_name = {"recipe-name.unpack",{"fluid-name.heavy-oil"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/heavy-oil-residue.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-heavy-oil-residue.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-heavy-oil",2}},
		results = {{"empty-canister",2}, {type="fluid",name="heavy-oil",amount=2}},
		main_product = "heavy-oil",
		energy_required = 6,
		category = "packaging",
		order = "d[heavy-oil]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- alumina solution
	{
		type = "item",
		name = "packaged-alumina-solution",
		icon = "__Satisfactorio__/graphics/icons/packaged-alumina-solution.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "e[alumina-solution]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = "packaged-alumina-solution",
		ingredients = {{"empty-canister",2}, {type="fluid",name="alumina-solution",amount=2}},
		result = "packaged-alumina-solution",
		result_count = 2,
		energy_required = 1,
		category = "packaging",
		order = "e[alumina-solution]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-alumina-solution",
		localised_name = {"recipe-name.unpack",{"fluid-name.alumina-solution"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/alumina-solution.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-alumina-solution.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-alumina-solution",2}},
		results = {{"empty-canister",2}, {type="fluid",name="alumina-solution",amount=2}},
		main_product = "alumina-solution",
		energy_required = 6,
		category = "packaging",
		order = "e[alumina-solution]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- sulfuric acid
	{
		type = "item",
		name = "packaged-sulfuric-acid",
		icon = "__Satisfactorio__/graphics/icons/packaged-sulfuric-acid.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "f[sulfuric-acid]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = "packaged-sulfuric-acid",
		ingredients = {{"empty-canister",2}, {type="fluid",name="sulfuric-acid",amount=2}},
		result = "packaged-sulfuric-acid",
		result_count = 2,
		energy_required = 3,
		category = "packaging",
		order = "f[sulfuric-acid]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-sulfuric-acid",
		localised_name = {"recipe-name.unpack",{"fluid-name.sulfuric-acid"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/sulfuric-acid.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-sulfuric-acid.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-sulfuric-acid",2}},
		results = {{"empty-canister",2}, {type="fluid",name="sulfuric-acid",amount=2}},
		main_product = "sulfuric-acid",
		energy_required = 1,
		category = "packaging",
		order = "f[sulfuric-acid]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- fuel
	{
		type = "item",
		name = "packaged-fuel",
		icon = "__Satisfactorio__/graphics/icons/packaged-fuel.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "g[fuel]",
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
		category = "packaging",
		order = "g[fuel]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-fuel",
		localised_name = {"recipe-name.unpack",{"fluid-name.fuel"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/fuel.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-fuel.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-fuel",2}},
		results = {{"empty-canister",2}, {type="fluid",name="fuel",amount=2}},
		main_product = "fuel",
		energy_required = 2,
		category = "packaging",
		order = "g[fuel]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- liquid biofuel
	{
		type = "item",
		name = "packaged-liquid-biofuel",
		icon = "__Satisfactorio__/graphics/icons/packaged-liquid-biofuel.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "h[liquid-biofuel]",
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
		category = "packaging",
		order = "h[liquid-biofuel]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-liquid-biofuel",
		localised_name = {"recipe-name.unpack",{"fluid-name.liquid-biofuel"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/liquid-biofuel.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-liquid-biofuel.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-liquid-biofuel",2}},
		results = {{"empty-canister",2}, {type="fluid",name="liquid-biofuel",amount=2}},
		main_product = "liquid-biofuel",
		energy_required = 2,
		category = "packaging",
		order = "h[liquid-biofuel]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- turbofuel
	{
		type = "item",
		name = "packaged-turbofuel",
		icon = "__Satisfactorio__/graphics/icons/packaged-turbofuel.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "i[turbofuel]",
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
		category = "packaging",
		order = "i[turbofuel]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-turbofuel",
		localised_name = {"recipe-name.unpack",{"fluid-name.turbofuel"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/turbofuel.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-turbofuel.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-turbofuel",2}},
		results = {{"empty-canister",2}, {type="fluid",name="turbofuel",amount=2}},
		main_product = "turbofuel",
		energy_required = 6,
		category = "packaging",
		order = "i[turbofuel]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- nitrogen gas
	{
		type = "item",
		name = "packaged-nitrogen-gas",
		icon = "__Satisfactorio__/graphics/icons/packaged-nitrogen-gas.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "j[nitrogen-gas]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = "packaged-nitrogen-gas",
		ingredients = {{"empty-fluid-tank",1}, {type="fluid",name="nitrogen-gas",amount=4}},
		result = "packaged-nitrogen-gas",
		result_count = 1,
		energy_required = 1,
		category = "packaging",
		order = "j[nitrogen-gas]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-nitrogen-gas",
		localised_name = {"recipe-name.unpack",{"fluid-name.nitrogen-gas"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/nitrogen-gas.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-nitrogen-gas.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-nitrogen-gas",1}},
		results = {{"empty-fluid-tank",1}, {type="fluid",name="nitrogen-gas",amount=4}},
		main_product = "nitrogen-gas",
		energy_required = 1,
		category = "packaging",
		order = "j[nitrogen-gas]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	-- nitric acid
	{
		type = "item",
		name = "packaged-nitric-acid",
		icon = "__Satisfactorio__/graphics/icons/packaged-nitric-acid.png",
		icon_size = 64,
		subgroup = "packed-fluid",
		order = "k[nitric-acid]",
		stack_size = 100
	},
	{
		type = "recipe",
		name = "packaged-nitric-acid",
		ingredients = {{"empty-fluid-tank",1}, {type="fluid",name="nitric-acid",amount=1}},
		result = "packaged-nitric-acid",
		result_count = 1,
		energy_required = 2,
		category = "packaging",
		order = "k[nitric-acid]",
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	},
	{
		type = "recipe",
		name = "unpack-nitric-acid",
		localised_name = {"recipe-name.unpack",{"fluid-name.nitric-acid"}},
		icons = {
			{icon = "__Satisfactorio__/graphics/icons/nitric-acid.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/packaged-nitric-acid.png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		ingredients = {{"packaged-nitric-acid",1}},
		results = {{"empty-fluid-tank",1}, {type="fluid",name="nitric-acid",amount=1}},
		main_product = "nitric-acid",
		energy_required = 3,
		category = "packaging",
		order = "k[nitric-acid]",
		subgroup = "unpack-fluid",
		hide_from_player_crafting = true,
		allow_decomposition = false,
		allow_intermediates = false,
		allow_as_intermediate = false,
		enabled = false
	}
})
