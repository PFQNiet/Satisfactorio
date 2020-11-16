-- tweak vanilla Pistol
local name = "rebar-gun"
local basename = "pistol"
local item = data.raw.gun[basename]
item.attack_parameters.ammo_category = "rebar"
item.attack_parameters.cooldown = 3.5*60
item.attack_parameters.range = 50
item.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
item.icon_mipmaps = 0
item.stack_size = 1

local ammo = "spiked-rebar"
data:extend({
	{
		type = "ammo",
		name = ammo,
		icon = "__Satisfactorio__/graphics/icons/"..ammo..".png",
		icon_size = 64,
		ammo_type = {
			category = "rebar",
			target_type = "direction",
			action = {
				{
					type = "direct",
					action_delivery = {
						{
							type = "projectile",
							projectile = ammo,
							starting_speed = 1,
							direction_deviation = 0.05,
							range_deviation = 0.15,
							max_range = 50,
							source_effects = {
								{
									type = "create-explosion",
									entity_name = "explosion-gunshot"
								}
							}
						}
					}
				}
			}
		},
		magazine_size = 1,
		subgroup = "ammo",
		order = "a[basic-clips]-1["..ammo.."]",
		stack_size = 50
	},
	{
		type = "projectile",
		name = ammo,
		flags = {"not-on-map"},
		collision_box = {{-0.5, -1}, {0.5, 1}},
		acceleration = -0.015,
		action = {
			type = "direct",
			action_delivery = {
				{
					type = "instant",
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit"
						},
						{
							type = "damage",
							damage = {amount=15,type="physical"}
						}
					}
				}
			}
		},
		animation = {
			filename = "__Satisfactorio__/graphics/particles/"..ammo..".png",
			frame_count = 1,
			width = 5,
			height = 50,
			priority = "high"
		},
		shadow = {
			filename = "__Satisfactorio__/graphics/particles/"..ammo..".png",
			frame_count = 1,
			width = 5,
			height = 50,
			priority = "high",
			draw_as_shadow = true
		},
		force_condition = "not-same",
		light = {
			intensity = 0.45,
			size = 5,
			color = {1,1,1}
		}
	},
	{
		name = basename,
		type = "recipe",
		ingredients = {
			{"reinforced-iron-plate",6},
			{"iron-stick",16},
			{"iron-gear-wheel",100}
		},
		result = basename,
		energy_required = 25/4,
		category = "equipment",
		enabled = false
	},
	{
		name = ammo,
		type = "recipe",
		ingredients = {
			{"iron-stick",1}
		},
		result = ammo,
		energy_required = 4,
		category = "constructing",
		enabled = false
	},
	{
		name = ammo.."-manual",
		type = "recipe",
		ingredients = {
			{"iron-stick",1}
		},
		result = ammo,
		energy_required = 1/4,
		category = "equipment",
		hide_from_player_crafting = true,
		enabled = false
	}
})
