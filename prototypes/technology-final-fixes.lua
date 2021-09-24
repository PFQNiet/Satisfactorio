-- products can be any item prototype, or a fluid
local prototype_lookup = table.deepcopy(defines.prototypes.item)
prototype_lookup.fluid = 0
local function getProductPrototype(name)
	for key in pairs(prototype_lookup) do
		assert(data.raw[key], "Key "..key.." not found in data.raw")
		local test = data.raw[key][name]
		if test then return test end
	end
	error("No prototype found for "..name)
end
local function getRecipeProduct(recipe)
	-- determine subgroup from main_product, or first product if no main_product is defined
	local product = recipe.main_product
	if not product then
		product = recipe.results and recipe.results[1] and (recipe.results[1].name or recipe.results[1][1]) or recipe.result
		assert(product, "No product found for "..recipe.name)
	end
	return product
end
local function getRecipeName(rname)
	-- unfortunately can't use recipe-name.rname, that'd be too easy...
	local recipe = data.raw.recipe[rname]
	if recipe.localised_name then return recipe.localised_name end
	local product = getRecipeProduct(recipe)
	assert(product, "No product found for recipe "..recipe.name)
	local proto = getProductPrototype(product)
	assert(proto, "No prototype found for product "..product)
	if proto.localised_name then return proto.localised_name end
	if proto.type == "fluid" then return {"fluid-name."..proto.name} end
	-- if item has a place_result then that result's name is used instead... which means searching ALL prototype types for it...
	if proto.place_result then
		for key in pairs(defines.prototypes.entity) do
			local test = data.raw[key][proto.place_result]
			if test then return test.localised_name or {"entity-name."..test.name} end
		end
	end
	return proto.localised_name or {"item-name."..proto.name}
end

local function isRecipeABuilding(rname)
	local recipe = data.raw.recipe[rname]
	return recipe.category == "building"
end
local function isRecipeAMaterial(rname)
	-- "material" recipe is any recipe in the "intermediate-products" or "space-elevator" groups
	local recipe = data.raw.recipe[rname]
	local subgroup = recipe.subgroup
	if not subgroup then
		local product = getRecipeProduct(recipe)
		subgroup = getProductPrototype(product).subgroup
		if not subgroup then return false end
	end
	local group = data.raw["item-subgroup"][subgroup].group
	return group == "intermediate-products" or group == "space-elevator"
end

for _,item in pairs(data.raw.tool) do
	if item.auto_generate_description then
		local description_groups = {
			building = {},
			equipment = {},
			material = {},
			resource = {},
			upgrade = {}
		}
		for _,effect in pairs(item.auto_generate_description) do
			if effect.type == "unlock-recipe" and effect.recipe:find("^hub%-tier%d+$") then
				-- don't add this to the description, that's included in "ficsit freighter added to hub"
			elseif effect.type == "unlock-recipe" then
				local subtype
				assert(data.raw.recipe[effect.recipe], "Recipe "..effect.recipe.." for item "..item.name.." was deleted")
				if data.raw.recipe[effect.recipe].category == "resource-scanner" then
					subtype = "resource"
				elseif isRecipeABuilding(effect.recipe) then
					subtype = "building"
				elseif isRecipeAMaterial(effect.recipe) then
					subtype = "material"
				else
					subtype = "equipment"
				end
				table.insert(description_groups[subtype], {"item-description.tech-result-line",{"item-description.tech-result-recipe", effect.recipe, getRecipeName(effect.recipe)}})
			elseif effect.type == "character-inventory-slots-bonus" then
				table.insert(description_groups.upgrade, {"item-description.tech-result-line",{"item-description.tech-result-inventory-expansion", effect.modifier}})
			elseif effect.type == "nothing" then
				table.insert(description_groups.upgrade, {"item-description.tech-result-line",effect.effect_description})
			elseif effect.type == "ghost-time-to-live" then
				-- do nothing
			else
				error("Unknown effect type "..effect.type.." for tech "..item.name)
			end
		end
		local description = {""}
		for _,key in pairs({"building", "equipment", "material", "resource", "upgrade"}) do
			local lines = description_groups[key]
			if #lines > 0 then
				table.insert(lines, 1, "")
				if #description > 1 then table.insert(description, "\n") end
				table.insert(description, {"item-description.tech-result-group", {"item-description.tech-result-"..key}, lines})
			end
		end

		item.localised_description = description
	end
end
