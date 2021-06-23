local tint1 = {64,48,55,1}
local tint2 = {242,110,242,1}

local biter = table.deepcopy(data.raw.unit["behemoth-spitter"])
biter.name = "alpha-spitter"
local attack = biter.attack_parameters
attack.damage_modifier = 20
attack.cooldown = 90
attack.cooldown_deviation = 0
attack.range = 20
attack.lead_target_for_projectile_speed = 0.5
attack.ammo_type.action.action_delivery.stream = "fire-stream-"..biter.name
attack.animation = spitterattackanimation(scale_spitter_behemoth, tint1, tint2)
biter.healing_per_tick = 0
biter.max_health = 80
biter.movement_speed = 0.25
biter.run_animation = spitterrunanimation(scale_spitter_behemoth, tint1, tint2)
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
biter.corpse = biter.name.."-corpse"

local corpse = table.deepcopy(data.raw.corpse["behemoth-spitter-corpse"])
corpse.name = biter.corpse
corpse.animation = spitterdyinganimation(scale_spitter_behemoth, tint1, tint2)

local stream = table.deepcopy(data.raw.stream["acid-stream-spitter-behemoth"])
stream.name = "fire-stream-"..biter.name
-- change to fireball
table.remove(stream.initial_action[1].action_delivery.target_effects,2) -- remove ground effect
stream.initial_action[2].action_delivery.target_effects[2].damage.type = "fire"
table.remove(stream.initial_action[2].action_delivery.target_effects,1) -- remove acid sticker
stream.particle_horizontal_speed = 0.5 -- was 0.3375

data:extend{biter, corpse, stream}
