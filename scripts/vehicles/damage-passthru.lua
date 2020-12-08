-- when a vehicle takes damage, pass it on to the player
local function onDamaged(event)
	if event.entity.type == "car" or event.entity.type == "spider-vehicle" then
		local damage = event.original_damage_amount
		if event.damage_type.name == "impact" then
			damage = math.max(0, (damage - 10) * 0.7)
		end
		local driver = event.entity.get_driver()
		if driver and not driver.is_player() then
			if event.cause then
				driver.damage(damage, event.force, event.damage_type.name, event.cause)
			else
				driver.damage(damage, event.force, event.damage_type.name)
			end
		elseif event.cause and event.cause.type == "unit" then
			event.cause.set_command{
				type = defines.command.stop,
				ticks_to_wait = 1
			}
		end
		local passenger = event.entity.get_passenger()
		if passenger and not passenger.is_player() then
			if event.cause then
				passenger.damage(damage, event.force, event.damage_type.name, event.cause)
			else
				passenger.damage(damage, event.force, event.damage_type.name)
			end
		end
	end
end

return {
	events = {
		[defines.events.on_entity_damaged] = onDamaged
	}
}

