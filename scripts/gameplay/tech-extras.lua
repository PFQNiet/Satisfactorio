---@type table<string, LuaTechnologyPrototype[]>
local tech_tree_cache = nil
-- Get technologies that depend on the given technology
---@param lookup LuaTechnology
---@return LuaTechnology[]
local function getDependents(lookup)
	if not tech_tree_cache then
		tech_tree_cache = {}
		for _,tech in pairs(game.technology_prototypes) do
			if game.recipe_prototypes[tech.name] then
				for _,req in pairs(tech.prerequisites) do
					if not tech_tree_cache[req.name] then tech_tree_cache[req.name] = {} end
					table.insert(tech_tree_cache[req.name], tech)
				end
			end
		end
	end
	local protos = tech_tree_cache[lookup.name]
	if not protos then return {} end
	local techs = {}
	for _,tech in pairs(protos) do
		table.insert(techs, lookup.force.technologies[tech.name])
	end
	return techs
end

---@alias ShopUnlockData table<string, table<string, boolean>> Map awesome shop recipe names to the technology(-ies) that unlocked them

---@class global.tech_extras
---@field shop_unlocks table<uint, ShopUnlockData> Force index => data
local script_data = {
	shop_unlocks = {}
}

-- Technology effects don't include -manual or awesome-shop- recipes, to avoid polluting the technology GUI. Instead they are unlocked here.
---@param event on_research_finished
local function onResearch(event)
	local technology = event.research
	local force = technology.force
	local frecipes = force.recipes
	for _,effect in pairs(technology.effects) do
		if effect.type == "unlock-recipe" then
			local recipe = game.recipe_prototypes[effect.recipe]
			if frecipes[recipe.name.."-manual"] then
				frecipes[recipe.name.."-manual"].enabled = true
			end
			for _,product in pairs(recipe.products) do
				if frecipes["awesome-shop-"..product.name] then
					if not script_data.shop_unlocks[product.name] then script_data.shop_unlocks[product.name] = {} end
					script_data.shop_unlocks[product.name][technology.name] = true

					frecipes["awesome-shop-"..product.name].enabled = true
				end
			end
		end
	end

	local candidates = getDependents(technology)
	if candidates then
		for _,tech in pairs(candidates) do
			local alldone = true
			for _,req in pairs(tech.prerequisites) do
				if not req.researched then
					alldone = false
					break
				end
			end
			if alldone then
				frecipes[tech.name].enabled = true
			end
		end
	end
	if frecipes[technology.name] and frecipes[technology.name.."-done"] then
		-- disable the recipe and enable the "-done" recipe
		frecipes[technology.name].enabled = false
		frecipes[technology.name.."-done"].enabled = true
	end

	if technology.name == "space-elevator-phase4" and not game.finished and game.tick > 5 and not global.no_victory then
		game.set_game_state{
			game_finished = true,
			player_won = true,
			can_continue = true,
			victorious_force = technology.force
		}
	end
end

-- If a tech is reverted in the editor, clean up its side-effects
---@param event on_research_reversed
local function onUnresearch(event)
	local technology = event.research
	local force = technology.force
	local frecipes = force.recipes
	for _,effect in pairs(technology.effects) do
		if effect.type == "unlock-recipe" then
			local recipe = game.recipe_prototypes[effect.recipe]
			if frecipes[recipe.name.."-manual"] then
				frecipes[recipe.name.."-manual"].enabled = false
			end
			for _,product in pairs(recipe.products) do
				if frecipes["awesome-shop-"..product.name] then
					if not script_data.shop_unlocks[product.name] then script_data.shop_unlocks[product.name] = {} end
					script_data.shop_unlocks[product.name][technology.name] = nil
					if not next(script_data.shop_unlocks[product.name]) then
						-- no other technology unlocked this product, disable it in the shop
						frecipes["awesome-shop-"..product.name].enabled = false
					end
				end
			end
		end
	end

	local candidates = getDependents(technology)
	if candidates then
		-- disable all dependents since they depend on the tech that just got reverted
		for _,tech in pairs(candidates) do
			frecipes[tech.name].enabled = false
		end
	end
	if frecipes[technology.name] and frecipes[technology.name.."-done"] then
		frecipes[technology.name].enabled = true
		frecipes[technology.name.."-done"].enabled = false
	end
end

---@param event on_technology_effects_reset
local function onTechEffectsReset(event)
	-- if/when a force's tech effects are reset, re-apply the unlocks above for all researched techs
	for _,tech in pairs(event.force.technologies) do
		if tech.researched then
			onResearch({research=tech})
		end
	end
end

return {
	on_init = function()
		-- setting this to true is done via remote interface
		global.no_victory = false
	end,
	events = {
		[defines.events.on_research_finished] = onResearch,
		[defines.events.on_research_reversed] = onUnresearch,
		[defines.events.on_technology_effects_reset] = onTechEffectsReset
	}
}
