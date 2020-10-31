-- "spore cloud", mostly invulnerable and emits continuous poison, can be killed by Nobelisk detonation
local worm = data.raw.turret['big-worm-turret']
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

-- uses vanilla poison cloud changes defined in behemoth-worm.lua
