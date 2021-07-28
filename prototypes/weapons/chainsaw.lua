local name = "chainsaw"
local saw = {
	type = "gun",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	stack_size = 1,
	subgroup = "melee",
	order = "s-x["..name.."]",
	attack_parameters = {
		type = "projectile",
		range = 2,
		cooldown = 1,
		movement_slow_down_factor = 0.75,
		movement_slow_down_cooldown = 20,
		ammo_category = "solid-biofuel",
		cyclic_sound = {
			begin_sound = {
				filename = "__base__/sound/car-engine-start.ogg",
				volume = 0.7
			},
			middle_sound = {
				filename = "__base__/sound/car-engine.ogg",
				volume = 0.7
			},
			end_sound = {
				filename = "__base__/sound/car-engine-stop.ogg",
				volume = 0.7
			}
		}
	}
}
local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"reinforced-iron-plate",5},
		{"iron-rod",25},
		{"screw",160},
		{"copper-cable",15}
	},
	result = name,
	energy_required = 15/4,
	category = "equipment",
	hide_from_stats = true,
	enabled = false
}

-- make all trees vulnerable to chainsaw damage
local default_mask = data.raw['utility-constants'].default.default_trigger_target_mask_by_type['tree'] or {'common'}
for _,tree in pairs(data.raw.tree) do
	if not tree.trigger_target_mask then tree.trigger_target_mask = default_mask end
	table.insert(tree.trigger_target_mask, "chainsawable")
end

data:extend({saw,recipe})
