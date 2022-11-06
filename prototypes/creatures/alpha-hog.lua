local tint1 = {64,48,55,1}
local tint2 = {242,110,242,1}

local biter = table.deepcopy(data.raw.unit["behemoth-biter"])
biter.name = "alpha-hog"
local attack = biter.attack_parameters
attack.ammo_type.action.action_delivery.target_effects.damage.amount = 20
attack.cooldown = 60
attack.cooldown_deviation = 0
attack.animation = biterattackanimation(behemoth_biter_scale, tint1, tint2)
biter.healing_per_tick = 0
biter.max_health = 80
biter.movement_speed = 0.3
biter.run_animation = biterrunanimation(behemoth_biter_scale, tint1, tint2)
biter.resistances = nil
biter.vision_distance = 30
biter.loot = {
	{
		item = "hog-remains",
		count_min = 3,
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

local corpse = table.deepcopy(data.raw.corpse["behemoth-biter-corpse"])
corpse.name = biter.corpse
corpse.animation = biterdieanimation(behemoth_biter_scale, tint1, tint2)

data:extend{biter, corpse}
