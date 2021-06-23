local tint1 = {64,58,48,1}
local tint2 = {242,228,110,1}

local biter = table.deepcopy(data.raw.unit['big-spitter'])
biter.name = "spitter"
local attack = biter.attack_parameters
attack.damage_modifier = 10
attack.cooldown = 90
attack.cooldown_deviation = 0
attack.range = 20
attack.ammo_type.action.action_delivery.stream = "fire-stream-"..biter.name
attack.animation = spitterattackanimation(scale_spitter_big, tint1, tint2)
biter.healing_per_tick = 0
biter.max_health = 40
biter.movement_speed = 0.15
biter.run_animation = spitterrunanimation(scale_spitter_big, tint1, tint2)
biter.resistances = nil
biter.vision_distance = 30
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
biter.corpse = biter.name.."-corpse"

local corpse = table.deepcopy(data.raw.corpse["big-spitter-corpse"])
corpse.name = biter.corpse
corpse.animation = spitterdyinganimation(scale_spitter_big, tint1, tint2)

local stream = table.deepcopy(data.raw.stream["acid-stream-spitter-big"])
stream.name = "fire-stream-"..biter.name
-- change to fireball
table.remove(stream.initial_action[1].action_delivery.target_effects,2) -- remove ground effect
stream.initial_action[2].action_delivery.target_effects[2].damage.type = "fire"
table.remove(stream.initial_action[2].action_delivery.target_effects,1) -- remove acid sticker

data:extend{biter, corpse, stream}
