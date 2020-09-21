local io = require("scripts.lualib.input-output")

local manufacturer = "manufacturer"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == manufacturer then
		io.addInput(entity, {-3,4.5})
		io.addInput(entity, {-1,4.5})
		io.addInput(entity, {1,4.5})
		io.addInput(entity, {3,4.5})
		io.addOutput(entity, {0,-4.5})
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == manufacturer then
		-- remove the input/output
		io.removeInput(entity, {-3,4.5}, event)
		io.removeInput(entity, {-1,4.5}, event)
		io.removeInput(entity, {1,4.5}, event)
		io.removeInput(entity, {3,4.5}, event)
		io.removeOutput(entity, {0,-4.5}, event)
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
