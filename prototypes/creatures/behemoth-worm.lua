-- "gas rock", completely invulnerable and emits continuous poison
local worm = data.raw.turret['behemoth-worm-turret']
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
				entity_name = "poison-cloud"
			}
		}
	}
}
attack.cooldown = 1200
attack.cooldown_deviation = 0
attack.damage_modifier = 1
attack.range = 84
worm.healing_per_tick = 0
worm.max_health = 9999
worm.resistances = nil
worm.call_for_help_radius = 0
worm.collision_box = worm.map_generator_bounding_box
worm.collision_mask = {"object-layer", "resource-layer"} -- can't be placed on objects or resources, but could appear on water
for i,flag in pairs(worm.flags) do
	if flag == "breaths-air" then
		table.remove(worm.flags,i)
		break
	end
end

-- make the vanilla poison cloud bigger
local cloud = data.raw['smoke-with-trigger']['poison-cloud']
cloud.created_effect[1].cluster_count = 18
cloud.created_effect[1].distance = 6
cloud.created_effect[1].distance_variation = 8
cloud.created_effect[3] = table.deepcopy(cloud.created_effect[1])
cloud.created_effect[3].distance = 10
cloud.created_effect[2].cluster_count = 25
cloud.created_effect[2].distance = 13.8
cloud.action.action_delivery.target_effects.action.radius = 16
cloud.action.action_delivery.target_effects.action.action_delivery.target_effects.damage.amount = 1
cloud.action_cooldown = 12 -- 5 dps
cloud.color = {0.239/2,0.992/2,0.426/2,0.69/2}

cloud = data.raw['smoke-with-trigger']['poison-cloud-visual-dummy']
cloud.color = {0.014/2,0.395/2,0.128/2,0.322/2}
