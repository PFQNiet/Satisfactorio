local biter = data.raw.unit['behemoth-spitter']
biter.attack_parameters.damage_modifier = 20
biter.attack_parameters.cooldown = 90
biter.attack_parameters.cooldown_deviation = 0
biter.attack_parameters.range = 20
biter.attack_parameters.lead_target_for_projectile_speed = 0.5
biter.healing_per_tick = 0
biter.max_health = 80
biter.movement_speed = 0.25
biter.resistances = nil
biter.vision_distance = 30
biter.loot = {
	{
		item = "alien-organs",
		count_min = 2,
		count_max = 3
	}
}
biter.ai_settings.destroy_when_commands_fail = false
biter.ai_settings.allow_try_return_to_spawner = false
for i,flag in pairs(biter.flags) do
	if flag == "breaths-air" then
		table.remove(biter.flags,i)
		break
	end
end

local stream = data.raw.stream['acid-stream-spitter-behemoth']
-- change to fireball
table.remove(stream.initial_action[1].action_delivery.target_effects,2) -- remove ground effect
stream.initial_action[2].action_delivery.target_effects[2].damage.type = "fire"
table.remove(stream.initial_action[2].action_delivery.target_effects,1) -- remove acid sticker
stream.particle_horizontal_speed = 0.5 -- was 0.3375
