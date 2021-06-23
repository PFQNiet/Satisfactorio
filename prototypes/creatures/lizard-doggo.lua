local biter = table.deepcopy(data.raw.unit['small-biter'])
biter.name = "lizard-doggo"
biter.attack_parameters.ammo_type.action.action_delivery.target_effects = nil
biter.attack_parameters.cooldown = 60
biter.attack_parameters.cooldown_deviation = 0
biter.healing_per_tick = 0
biter.max_health = 15
biter.movement_speed = 0.15
biter.resistances = nil
biter.vision_distance = 30
biter.ai_settings.destroy_when_commands_fail = false
biter.ai_settings.allow_try_return_to_spawner = false
for i,flag in pairs(biter.flags) do
	if flag == "breaths-air" then
		table.remove(biter.flags,i)
		break
	end
end

data:extend{biter}
