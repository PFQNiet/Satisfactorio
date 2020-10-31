local biter = data.raw.unit['big-spitter']
biter.attack_parameters.damage_modifier = 10
biter.attack_parameters.cooldown = 120
biter.attack_parameters.cooldown_deviation = 0
biter.attack_parameters.range = 20
biter.healing_per_tick = 0
biter.max_health = 40
biter.movement_speed = 0.15
biter.resistances = nil
biter.vision_distance = 20
biter.loot = {
	{
		item = "alien-organs",
		count_min = 1,
		count_max = 1
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

local stream = data.raw.stream['acid-stream-spitter-big']
-- change to fireball
table.remove(stream.initial_action[1].action_delivery.target_effects,2) -- remove ground effect
stream.initial_action[2].action_delivery.target_effects[2].damage.type = "fire"
table.remove(stream.initial_action[2].action_delivery.target_effects,1) -- remove acid sticker
