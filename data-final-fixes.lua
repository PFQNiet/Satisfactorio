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

-- verify that any "building"-type recipes have their product set to "only-in-cursor"
local function findItemByName(name)
	for key in pairs(defines.prototypes.item) do
		local test = data.raw[key][name]
		if test then return test end
	end
end
for _,recipe in pairs(data.raw.recipe) do
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
end

require("prototypes.technology-final-fixes")
