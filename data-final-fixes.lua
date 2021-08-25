-- ensure no mods have added techs using Science Packs that haven't been made compatible
local vanillapacks = {
	["automation-science-pack"] = true,
	["logistic-science-pack"] = true,
	["military-science-pack"] = true,
	["chemical-science-pack"] = true,
	["production-science-pack"] = true,
	["utility-science-pack"] = true,
	["space-science-pack"] = true
}
for _,tech in pairs(data.raw.technology) do
	if tech.enabled and not tech.hidden then
		for _,item in pairs(tech.unit.ingredients) do
			if vanillapacks[item[1] or item.name] then
				error("Technology "..tech.name.." uses "..(item[1] or item.name)..", which is unsupported by Satisfactorio.")
			end
		end
	end
end

-- anything that would collide with objects or rails, except for actual (straight) rails should collide with platforms
local maskutil = require("collision-mask-util")
for _,entity in pairs(maskutil.collect_prototypes_colliding_with_mask{"object-layer","rail-layer"}) do
	if entity.type ~= "straight-rail" then
		local mask = maskutil.get_mask(entity)
		maskutil.add_layer(mask,train_platform_layer)
		entity.collision_mask = mask
	end
end

local function findItemByName(name)
	for key in pairs(defines.prototypes.item) do
		local test = data.raw[key][name]
		if test then return test end
	end
end
local function recipeIngredientsByType(recipe)
	local result = {item=0,fluid=0}
	for _,ingredient in pairs(recipe.ingredients) do
		local type = ingredient.type or "item"
		result[type] = result[type] + 1
	end
	return result
end
for _,recipe in pairs(data.raw.recipe) do
	-- verify that any "building"-type recipes have their product set to "only-in-cursor"
	if recipe.category == "building" then
		local product = findItemByName(recipe.result) -- building recipes always have a single result property
		assert(product, "No product found for building recipe "..recipe.name)
		local has_oic_flag = false
		for _,flag in pairs(product.flags or {}) do
			if flag == "only-in-cursor" then
				has_oic_flag = true
				break
			end
		end
		if not has_oic_flag then
			log("[WARN] Product "..product.name.." is missing the only-in-cursor flag")
			if not product.flags then product.flags = {} end
			table.insert(product.flags, "only-in-cursor")
		end
	end

	-- verify that construction recipes have the correct number of ingredients
	if recipe.category == "constructing" then
		assert(#recipe.ingredients == 1, "Recipe "..recipe.name.." has "..#recipe.ingredients.." ingredients but category "..recipe.category.." supports 1.")
	end
	if recipe.category == "assembling" then
		assert(#recipe.ingredients == 2, "Recipe "..recipe.name.." has "..#recipe.ingredients.." ingredients but category "..recipe.category.." supports 2.")
	end
	if recipe.category == "manufacturing" then
		assert(#recipe.ingredients == 3 or #recipe.ingredients == 4, "Recipe "..recipe.name.." has "..#recipe.ingredients.." ingredients but category "..recipe.category.." supports 3 or 4.")
	end
	if recipe.category == "packaging" then
		local ingredients = recipeIngredientsByType(recipe)
		assert(ingredients.item <= 1, "Recipe "..recipe.name.." has "..ingredients.item.." item ingredients but category "..recipe.category.." supports 0 or 1.")
		assert(ingredients.fluid <= 1, "Recipe "..recipe.name.." has "..ingredients.item.." fluid ingredients but category "..recipe.category.." supports 0 or 1.")
	end
	if recipe.category == "refining" then
		local ingredients = recipeIngredientsByType(recipe)
		assert(ingredients.item <= 1, "Recipe "..recipe.name.." has "..ingredients.item.." item ingredients but category "..recipe.category.." supports 0 or 1.")
		assert(ingredients.fluid <= 1, "Recipe "..recipe.name.." has "..ingredients.item.." fluid ingredients but category "..recipe.category.." supports 0 or 1.")
	end
	if recipe.category == "blending" then
		local ingredients = recipeIngredientsByType(recipe)
		assert(ingredients.item <= 2, "Recipe "..recipe.name.." has "..ingredients.item.." item ingredients but category "..recipe.category.." supports 0 or 1 or 2.")
		assert(ingredients.fluid <= 2, "Recipe "..recipe.name.." has "..ingredients.item.." fluid ingredients but category "..recipe.category.." supports 0 or 1 or 2.")
	end
	if recipe.category == "accelerating" then
		local ingredients = recipeIngredientsByType(recipe)
		assert(ingredients.item <= 2, "Recipe "..recipe.name.." has "..ingredients.item.." item ingredients but category "..recipe.category.." supports 0 or 1 or 2.")
		assert(ingredients.fluid <= 1, "Recipe "..recipe.name.." has "..ingredients.item.." fluid ingredients but category "..recipe.category.." supports 0 or 1.")
	end
	if recipe.category == "smelter" then
		assert(#recipe.ingredients == 1, "Recipe "..recipe.name.." has "..#recipe.ingredients.." ingredients but category "..recipe.category.." supports 1.")
	end
	if recipe.category == "foundry" then
		assert(#recipe.ingredients == 2, "Recipe "..recipe.name.." has "..#recipe.ingredients.." ingredients but category "..recipe.category.." supports 2.")
	end
	if recipe.category == "craft-bench" or recipe.category == "equipment" then
		local ingredients = recipeIngredientsByType(recipe)
		assert(ingredients.fluid == 0, "Recipe "..recipe.name.." has "..ingredients.item.." fluid ingredients but category "..recipe.category.." supports 0.")
	end
end

require("prototypes.technology-final-fixes")
