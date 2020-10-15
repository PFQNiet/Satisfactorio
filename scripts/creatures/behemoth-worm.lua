-- it already has 9999 health, let's make it invulnerable for good measure!
local name = "behemoth-worm-turret"
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name ~= name then return end
	entity.destructible = false
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt
	}
}
