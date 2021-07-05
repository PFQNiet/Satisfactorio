local tech_tree_cache = nil
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
					frecipes["awesome-shop-"..product.name].enabled = true
				end
			end
		end
	end

	-- find techs that depend on the tech we just did, and unlock their associated recipe items
	if not tech_tree_cache then
		-- map techs to the things they unlock
		tech_tree_cache = {}
		for _,tech in pairs(technology.force.technologies) do
			if frecipes[tech.name] then
				for _,req in pairs(tech.prerequisites) do
					if not tech_tree_cache[req.name] then tech_tree_cache[req.name] = {} end
					table.insert(tech_tree_cache[req.name], tech)
				end
			end
		end
	end
	local candidates = tech_tree_cache[technology.name]
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

	if technology.name == "space-elevator-phase4" and not game.finished and event.tick > 5 then
		game.set_game_state{
			game_finished = true,
			player_won = true,
			can_continue = true,
			victorious_force = technology.force
		}
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
	events = {
		[defines.events.on_research_finished] = onResearch,
		[defines.events.on_technology_effects_reset] = onTechEffectsReset
	}
}
