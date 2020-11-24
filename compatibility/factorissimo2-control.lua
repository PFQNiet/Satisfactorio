return {
	events = {
		[defines.events.on_research_finished] = function(event)
			if game.active_mods['Factorissimo2'] then
				if event.research.name == "hub-tier1-base-building" then
					-- set Factorissimo "upgrade" techs to researched
					for _,k in pairs({"factory-interior-upgrade-lights", "factory-interior-upgrade-display", "factory-preview", "factory-recursion-t1", "factory-recursion-t2"}) do
						event.research.force.technologies[k].researched = true
					end
				end
				if event.research.name == "hub-tier3-coal-power" then
					-- set Factorissimo "fluid connection" tech to researched
					event.research.force.technologies["factory-connection-type-fluid"].researched = true
				end
			end
		end
	}
}
