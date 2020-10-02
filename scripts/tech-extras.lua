-- Technology effects don't include -manual, -undo or awesome-shop- recipes, to avoid polluting the technology GUI
-- Instead they are unlocked here.
function onResearch(event)
	local technology = event.research
	for _,effect in pairs(technology.effects) do
		if effect.type == "unlock-recipe" then
			if technology.force.recipes[effect.recipe.."-undo"] then
				technology.force.recipes[effect.recipe.."-undo"].enabled = true
			end
			if technology.force.recipes[effect.recipe.."-manual"] then
				technology.force.recipes[effect.recipe.."-manual"].enabled = true
			end
			if technology.force.recipes["awesome-shop-"..effect.recipe] then
				technology.force.recipes["awesome-shop-"..effect.recipe].enabled = true
			end
		end
	end
	-- find techs that depend on the tech we just did, and unlock their associated recipe items
	for _,tech in pairs(technology.force.technologies) do
		if technology.force.recipes[tech.name] then
			local match = false
			local alldone = true
			for _,req in pairs(tech.prerequisites) do
				if not req.researched then
					alldone = false
					break
				end
				if req.name == technology.name then
					match = true
				end
			end
			if match and alldone then
				technology.force.recipes[tech.name].enabled = true
			end
		end
	end
end

return {
	events = {
		[defines.events.on_research_finished] = onResearch
	}
}
