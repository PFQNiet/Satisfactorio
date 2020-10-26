local biter = data.raw.unit['big-biter']
biter.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount = 10
biter.attack_parameters.cooldown = 60
biter.attack_parameters.cooldown_deviation = 0
biter.healing_per_tick = 0
biter.max_health = 20
biter.movement_speed = 0.2
biter.resistances = nil
biter.vision_distance = 20
biter.loot = {
	{
		item = "alien-carapace",
		count_min = 1,
		count_max = 1
	}
}
biter.ai_settings.destroy_when_commands_fail = false
for i,flag in pairs(biter.flags) do
	if flag == "breaths-air" then
		table.remove(biter.flags,i)
		break
	end
end
