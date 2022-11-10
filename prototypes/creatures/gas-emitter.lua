-- "gas rock", completely invulnerable and emits continuous poison
local worm = table.deepcopy(data.raw.turret['behemoth-worm-turret'])
worm.name = "gas-emitter"
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
-- make vulnerable to nobelisk damage, but will only actually die if it's a nuke!
if not worm.trigger_target_mask then worm.trigger_target_mask = data.raw['utility-constants'].default.default_trigger_target_mask_by_type['turret'] or {'common'} end
table.insert(worm.trigger_target_mask, "nobelisk-nukable")

-- make the vanilla poison cloud bigger
local cloud = table.deepcopy(data.raw['smoke-with-trigger']['poison-cloud'])
cloud.name = "toxic-gas-cloud"
cloud.created_effect[1].cluster_count = 18
cloud.created_effect[1].distance = 6
cloud.created_effect[1].distance_variation = 8
cloud.created_effect[1].action_delivery.target_effects[1].entity_name = "toxic-cloud-visual-dummy"
cloud.created_effect[3] = table.deepcopy(cloud.created_effect[1])
cloud.created_effect[3].distance = 10
cloud.created_effect[2].cluster_count = 25
cloud.created_effect[2].distance = 13.8
cloud.created_effect[2].action_delivery.target_effects[1].entity_name = "toxic-cloud-visual-dummy"
cloud.action.action_delivery.target_effects.action.radius = 16
cloud.action.action_delivery.target_effects.action.action_delivery.target_effects.damage.amount = 1
cloud.action_cooldown = 12 -- 5 dps
cloud.color = {0.239/2,0.992/2,0.426/2,0.69/2}

local cloud2 = table.deepcopy(data.raw['smoke-with-trigger']['poison-cloud-visual-dummy'])
cloud2.name = "toxic-cloud-visual-dummy"
cloud2.color = {0.014/2,0.395/2,0.128/2,0.322/2}

data:extend{worm, cloud, cloud2} -- keep same corpse/animations for now

data:extend{
	{
		type = "autoplace-control",
		name = "gas-emitter",
		order = "d",
		richness = false,
		category = "enemy"
	},
	{
		type = "noise-layer",
		name = "gas-emittter"
	}
}