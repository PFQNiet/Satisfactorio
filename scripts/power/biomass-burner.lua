local powertrip = require("scripts.lualib.power-trip")

local burner = "biomass-burner"
local burner_hub = "biomass-burner-hub"
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == burner or entity.name == burner_hub then
		powertrip.registerGenerator(entity, entity.name.."-accumulator", entity.burner)
	end
end
local function onRemoved(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == burner or entity.name == burner_hub then
		powertrip.unregisterGenerator(entity)
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved
	}
}
