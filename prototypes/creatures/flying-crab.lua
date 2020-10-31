local botsource = table.deepcopy(data.raw['combat-robot']['defender'])
botsource.in_motion.layers[1].shift[2] = botsource.in_motion.layers[1].shift[2] - 0.8
botsource.in_motion.layers[2].shift[2] = botsource.in_motion.layers[2].shift[2] - 0.8
botsource.shadow_in_motion.shift[2] = botsource.shadow_in_motion.shift[2] - 0.8
botsource.in_motion.layers[1].hr_version.shift[2] = botsource.in_motion.layers[1].hr_version.shift[2] - 0.8
botsource.in_motion.layers[2].hr_version.shift[2] = botsource.in_motion.layers[2].hr_version.shift[2] - 0.8
botsource.shadow_in_motion.hr_version.shift[2] = botsource.shadow_in_motion.hr_version.shift[2] - 0.8
local biter = {
	type = "unit",
	name = "flying-crab",
	run_animation = {
		layers = {
			botsource.in_motion,
			botsource.shadow_in_motion
		}
	},
	attack_parameters = {
		ammo_type = {
			category = "melee",
			target_type = "entity",
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					target_effects = {
						{
							type = "damage",
							damage = {
								amount = 5,
								type = "physical"
							}
						},
						{
							type = "script",
							effect_id = "crab-impact"
						}
					}
				}
			}
		},
		animation = {
			layers = {
				botsource.in_motion,
				botsource.shadow_in_motion
			}
		},
		cooldown = 5,
		cooldown_deviation = 0,
		range = 1.5,
		sound = botsource.attack_parameters.sound,
		type = "projectile"
	},
	movement_speed = 0.35,
	distance_per_frame = 1,
	pollution_to_join_attack = 10,
	distraction_cooldown = 300,
	vision_distance = 30,
	dying_trigger_effect = botsource.dying_trigger_effect,
	has_belt_immunity = true,
	-- default ai_settings are fine
	render_layer = "air-object",
	working_sound = botsource.working_sound,
	max_health = 6,
	collision_box = botsource.collision_box,
	selection_box = botsource.selection_box,
	collision_mask = {},
	flags = {
		"placeable-off-grid",
		"not-repairable"
	},
	icon = botsource.icon,
	icon_mipmaps = botsource.icon_mipmaps,
	icon_size = botsource.icon_size,
	sticker_box = botsource.selection_box,
	subgroup = "enemies"
}

data:extend{biter}

-- spawner is a "turret" that self-destructs
-- entity spawns three crabs on death
-- repurpose the small worm turret for this
local worm = data.raw.turret['small-worm-turret']
local attack = worm.attack_parameters
attack.type = "projectile"
attack.ammo_type = {
	category = "biological",
	action = {
		type = "direct",
		action_delivery = {
			type = "instant",
			source_effects = {
				type = "script",
				effect_id = "crab-spawn"
			}
		}
	}
}
attack.cooldown = 1200
attack.cooldown_deviation = 0
attack.damage_modifier = 1
attack.range = 20
worm.healing_per_tick = 0
worm.max_health = 0.99
worm.resistances = nil
worm.call_for_help_radius = 0
worm.loot = {
	{
		item = "alien-carapace",
		count_min = 1,
		count_max = 1
	}
}
worm.collision_mask = {"object-layer", "resource-layer"} -- can't be placed on objects or resources, but could appear on water
for i,flag in pairs(worm.flags) do
	if flag == "breaths-air" then
		table.remove(worm.flags,i)
		break
	end
end
