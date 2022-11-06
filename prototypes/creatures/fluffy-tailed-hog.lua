local tint1 = {64,58,48,1}
local tint2 = {242,228,110,1}

local biter = table.deepcopy(data.raw.unit["big-biter"])
biter.name = "fluffy-tailed-hog"
local attack = biter.attack_parameters
attack.ammo_type.action.action_delivery.target_effects.damage.amount = 10
attack.cooldown = 60
attack.cooldown_deviation = 0
attack.animation = biterattackanimation(big_biter_scale, tint1, tint2)
biter.healing_per_tick = 0
biter.max_health = 20
biter.movement_speed = 0.2
biter.run_animation = biterrunanimation(big_biter_scale, tint1, tint2)
biter.resistances = nil
biter.vision_distance = 30
biter.loot = {
	{
		item = "hog-remains",
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
biter.corpse = biter.name.."-corpse"

local corpse = table.deepcopy(data.raw.corpse["big-biter-corpse"])
corpse.name = biter.corpse
corpse.animation = biterdieanimation(big_biter_scale, tint1, tint2)

data:extend{biter, corpse}
