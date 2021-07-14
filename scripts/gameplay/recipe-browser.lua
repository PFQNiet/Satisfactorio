local browser = require(modpath.."scripts.gui.recipe-browser")

---@param player LuaPlayer
---@param search Product
browser.callbacks.search = function(player, search)
	---@type LuaRecipePrototype[]
	local matching_recipes = {}
	---@type table<string, boolean>
	local potential_recipes = {}
	local search_proto = game[search.type.."_prototypes"][search.name]
	for _,recipe in pairs(player.force.recipes) do
		local recipe_proto = recipe.prototype
		if not recipe_proto.hidden_from_player_crafting then
			-- check if any products match
			local match = false
			for _,product in pairs(recipe.products) do
				if product.type == search.type and product.name == search.name then
					match = true
					break
				end
			end
			if match then
				-- "potential" is used if no matching one is found, to show techs to unlock. therefore, ignore by-product recipes for this
				if recipe_proto.main_product.type == search.type and recipe_proto.main_product.name == search.name then
					potential_recipes[recipe.name] = true
				end
				if recipe.enabled then
					table.insert(matching_recipes, recipe_proto)
				end
			end
		end
	end
	-- find tech(s) that unlock this, but exclude alt-recipe techs, except alt-exclusive recipes
	if #matching_recipes == 0 then
		---@type LuaTechnology[]
		local techs = {}
		local alt_only = {
			["alt-heavy-oil-residue"] = true,
			["alt-polymer-resin"] = true,
			["alt-compacted-coal"] = true,
			["alt-turbofuel"] = true
		}
		for _,tech in pairs(player.force.technologies) do
			if tech.enabled and (not tech.prototype.hidden) and ((tech.research_unit_ingredients[1] and tech.research_unit_ingredients[1].name ~= "hard-drive") or alt_only[tech.name]) then
				for _,result in pairs(tech.effects) do
					if result.type == "unlock-recipe" and potential_recipes[result.recipe] then
						table.insert(techs,tech)
						break
					end
				end
			end
		end
		browser.show_techs(player, search_proto, techs)
	else
		---@param a LuaRecipePrototype
		---@param b LuaRecipePrototype
		table.sort(matching_recipes, function(a,b)
			-- prioritise recipes where the main product doesn't exist, or is the searched product
			local a_main = a.main_product.type == search.type and a.main_product.name == search.name
			local b_main = b.main_product.type == search.type and b.main_product.name == search.name
			if a_main ~= b_main then
				return a_main
			elseif a.group ~= b.group then
				return a.group.order < b.group.order
			elseif a.subgroup ~= b.subgroup then
				return a.subgroup.order < b.subgroup.order
			else
				return a.order < b.order
			end
		end)
		browser.show_recipes(player, search_proto, matching_recipes)
	end
end

return {
	events = {
		["recipe-browser"] = function(event)
			browser.toggle_gui(game.players[event.player_index])
		end,
		[defines.events.on_lua_shortcut] = function(event)
			if event.prototype_name == "recipe-browser" then
				browser.toggle_gui(game.players[event.player_index])
			end
		end
	}
}
