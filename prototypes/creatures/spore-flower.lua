-- "spore flower", mostly invulnerable and emits continuous poison, can be killed by Nobelisk detonation
local worm = table.deepcopy(data.raw.turret['big-worm-turret'])
worm.name = "spore-flower"
local attack = worm.attack_parameters
attack.type = "projectile"
attack.ammo_type = {
	category = "biological",
	action = {
		type = "direct",
		action_delivery = {
			type = "instant",
			source_effects = {
				type = "create-smoke",
				initial_height = 0,
				show_in_tooltip = true,
				entity_name = "toxic-gas-cloud"
			}
		}
	}
}
attack.cooldown = 1200
attack.cooldown_deviation = 0
attack.damage_modifier = 1
attack.range = 84
worm.healing_per_tick = 0
worm.max_health = 1
worm.resistances = nil
worm.call_for_help_radius = 0
worm.map_generator_bounding_box = {{-3.4,-3.2},{3.4,3.2}}
worm.collision_mask = {"object-layer", "resource-layer"} -- can't be placed on objects or resources, but could appear on water
for i,flag in pairs(worm.flags) do
	if flag == "breaths-air" then
		table.remove(worm.flags,i)
		break
	end
end
-- make vulnerable to nobelisk damage
if not worm.trigger_target_mask then worm.trigger_target_mask = data.raw['utility-constants'].default.default_trigger_target_mask_by_type['turret'] or {'common'} end
table.insert(worm.trigger_target_mask, "nobelisk-explodable")

-- uses vanilla poison cloud changes defined in gas-emitter.lua
data:extend{worm}
