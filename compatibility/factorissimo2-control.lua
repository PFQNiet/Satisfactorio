if not script.active_mods['Factorissimo2'] then return {} end

local function applyUpgrades(force)
	-- set Factorissimo "upgrade" techs to researched
	for _,k in pairs({"factory-interior-upgrade-lights", "factory-interior-upgrade-display", "factory-preview", "factory-recursion-t1", "factory-recursion-t2"}) do
		force.technologies[k].researched = true
	end
end
local function allowFluids(force)
	-- set Factorissimo "fluid connection" tech to researched
	force.technologies["factory-connection-type-fluid"].researched = true
end

return {
	events = {
		[defines.events.on_research_finished] = function(event)
			if event.research.name == "hub-tier1-base-building" then
				applyUpgrades(event.research.force)
			end
			if event.research.name == "hub-tier3-coal-power" then
				allowFluids(event.research.force)
			end
		end,
		[defines.events.on_technology_effects_reset] = function (event)
			if event.force.technologies['hub-tier1-base-building'] then
				applyUpgrades(event.force)
			end
			if event.force.technologies['hub-tier3-coal-power'] then
				allowFluids(event.force)
			end
		end
	}
}
