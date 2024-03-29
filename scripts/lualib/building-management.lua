local cache = {}
---@param name string
---@return LuaRecipePrototype|nil
local function getBuildingRecipe(name)
	local cached = cache[name]
	if cached == "NONE" then return nil end
	if cached then return cached end

	if not name then return nil end
	local item = game.item_prototypes[name]
	if not item then
		-- try looking up by entity
		local entity = game.entity_prototypes[name]
		if not entity then return nil end
		local place = entity.items_to_place_this
		if not place then return nil end
		for _,i in pairs(place) do
			local attempt = getBuildingRecipe(i.name)
			if attempt then
				cache[name] = attempt
				return attempt
			end
		end
	else
		-- now search recipes for one that produces this (in the "building" category)
		for _,recipe in pairs(game.recipe_prototypes) do
			if recipe.category == "building" then
				-- all "building" recicpes have a single product, that is the building
				if recipe.products[1].name == item.name then
					cache[name] = recipe
					return recipe
				end
			end
		end
	end
	cache[name] = "NONE"
end

-- if the entity has an undo recipe, refund the components instead
---@param player LuaPlayer
---@param entity LuaEntity
local function refundEntity(player, entity)
	if not (player and player.cheat_mode) then
		local recipe = getBuildingRecipe(entity.name)
		local insert = recipe and recipe.ingredients or {{name=entity.name,amount=1}}
		for _,refund in pairs(insert) do
			local spill = refund.amount
			if player then spill = spill - player.insert{name=refund.name,count=refund.amount} end
			if spill > 0 then
				(player or entity).surface.spill_item_stack(
					(player or entity).position,
					{name = refund.name, count = spill},
					true, player and player.force or nil, false
				)
			end
		end
	end
	entity.destroy{raise_destroy=true} -- allow IO to snap loader belts back
end

return {
	getBuildingRecipe = getBuildingRecipe,
	refundEntity = refundEntity
}
