-- when an enemy takes impact damage, give them a "flee" command so they don't just get ground up
---@param event on_entity_damaged
local function onDamaged(event)
	if event.entity.type == "unit" and event.damage_type.name == "impact" and event.cause and event.final_health > 0 then
		event.entity.set_command{
			type = defines.command.flee,
			from = event.cause,
			distraction = defines.distraction.none
		}
	end
end

return {
	events = {
		[defines.events.on_entity_damaged] = onDamaged
	}
}
