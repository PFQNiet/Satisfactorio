local name = "drone"
-- code "borrowed" from Companion Drones
local dronesize = 1.6
local drone = {
	type = "spider-vehicle",
	name = name,
	collision_box = {{-1 * dronesize, -1 * dronesize}, {1 * dronesize, 1 * dronesize}},
	selection_box = {{-1 * dronesize, -1 * dronesize}, {1 * dronesize, 1 * dronesize}},
	drawing_box = {{-3 * dronesize, -4 * dronesize}, {3 * dronesize, 2 * dronesize}},
	icon = "__Satisfactorio__/graphics/icons/drone.png",
	icon_size = 64,
	mined_sound = {filename = "__core__/sound/deconstruct-large.ogg",volume = 0.8},
	open_sound = { filename = "__base__/sound/spidertron/spidertron-door-open.ogg", volume= 0.35 },
	close_sound = { filename = "__base__/sound/spidertron/spidertron-door-close.ogg", volume = 0.4 },
	sound_minimum_speed = 0.3,
	sound_scaling_ratio = 0.1,
	allow_passengers = false,
	working_sound = {
		sound = {
			filename = "__base__/sound/spidertron/spidertron-vox.ogg",
			volume = 0.35
		},
		activate_sound = {
			filename = "__base__/sound/spidertron/spidertron-activate.ogg",
			volume = 0.5
		},
		deactivate_sound = {
			filename = "__base__/sound/spidertron/spidertron-deactivate.ogg",
			volume = 0.5
		},
		match_speed_to_activity = true
	},
	weight = 1,
	braking_force = 1,
	friction_force = 1,
	flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
	collision_mask = {},
	minable = {result = name, mining_time = 0.5},
	max_health = 1,
	energy_per_hit_point = 1,
	guns = {},
	inventory_size = 9,
	trash_inventory_size = 0,
	height = 2,
	torso_rotation_speed = 0.05,
	chunk_exploration_radius = 0,
	selection_priority = 55,
	graphics_set = spidertron_torso_graphics_set(dronesize),
	base_render_layer = "smoke",
	render_layer = "air-object",
	energy_source = {
		type = "burner",
		fuel_category = "battery",
		effectivity = 1,
		fuel_inventory_size = 1
	},
	movement_energy_consumption = "400MW",
	automatic_weapon_cycling = true,
	chain_shooting_cooldown_modifier = 0.5,
	spider_engine = {
		legs = {
			{ -- 1
				leg = name.."-leg",
				mount_position = {0, -1},
				ground_position = {0, -1},
				blocking_legs = {1},
				leg_hit_the_ground_trigger = nil
			}
		},
		military_target = "spidertron-military-target"
	},

	minimap_representation = {
		filename = "__Satisfactorio__/graphics/particles/drone-map.png",
		flags = {"icon"},
		size = {128, 128},
		scale = 0.25
	}

}
drone.graphics_set.render_layer = "air-entity-info-icon"
drone.graphics_set.base_render_layer = "air-object"
drone.graphics_set.autopilot_path_visualisation_line_width = 0
drone.graphics_set.autopilot_path_visualisation_on_map_line_width = 0
drone.graphics_set.autopilot_destination_visualisation = util.empty_sprite()
drone.graphics_set.autopilot_destination_queue_on_map_visualisation = util.empty_sprite()
drone.graphics_set.autopilot_destination_on_map_visualisation = util.empty_sprite()
drone.graphics_set.light = {
	{
		type = "oriented",
		minimum_darkness = 0.3,
		picture = {
			filename = "__core__/graphics/light-cone.png",
			priority = "extra-high",
			flags = { "light" },
			scale = 1,
			width = 200,
			height = 200,
			shift = {0, -1}
		},
		source_orientation_offset = 0,
		shift = {0, (-200/32)- 0.5},
		add_perspective = false,
		size = 2,
		intensity = 0.6,
		color = {r = 0.92, g = 0.77, b = 0.3}
	}
}
drone.graphics_set.eye_light.size = 0

local leg = {
	type = "spider-leg",
	name = name.."-leg",
	localised_name = {"entity-name.spidertron-leg"},
	collision_box = nil,
	collision_mask = {},
	selection_box = {{-0, -0}, {0, 0}},
	icon = "__base__/graphics/icons/spidertron.png",
	icon_size = 64, icon_mipmaps = 4,
	walking_sound_volume_modifier = 0,
	target_position_randomisation_distance = 0,
	minimal_step_size = 0,
	working_sound = nil,
	part_length = 1000000000,
	initial_movement_speed = 100,
	movement_acceleration = 100,
	max_health = 100,
	movement_based_position_selection_distance = 3,
	selectable_in_game = false,
	graphics_set = create_spidertron_leg_graphics_set(0, 1)
}

local layers = drone.graphics_set.base_animation.layers
for k, layer in pairs (layers) do
	layer.repeat_count = 8
	layer.hr_version.repeat_count = 8
end

table.insert(layers, 1, {
	filename = "__base__/graphics/entity/rocket-silo/10-jet-flame.png",
	priority = "medium",
	blend_mode = "additive",
	draw_as_glow = true,
	width = 87,
	height = 128,
	frame_count = 8,
	line_length = 8,
	animation_speed = 0.5,
	scale = 1/2*dronesize,
	shift = util.by_pixel(-0.5, 20*dronesize),
	direction_count = 1,
	hr_version = {
		filename = "__base__/graphics/entity/rocket-silo/hr-10-jet-flame.png",
		priority = "medium",
		blend_mode = "additive",
		draw_as_glow = true,
		width = 172,
		height = 256,
		frame_count = 8,
		line_length = 8,
		animation_speed = 0.5,
		scale = 1/4*dronesize,
		shift = util.by_pixel(-1, 20*dronesize),
		direction_count = 1,
	}
})

local speed_sticker = {
	type = "sticker",
	name = name.."-speed-sticker",
	flags = {"not-on-map"},
	animation = util.empty_sprite(),
	duration_in_ticks = 100,
	target_movement_modifier_from = 1,
	target_movement_modifier_to = 1,
	vehicle_speed_modifier_from = 5,
	vehicle_speed_modifier_to = 5,
	vehicle_friction_modifier_from = 1,
	vehicle_friction_modifier_to = 1
}

local drone_item = {
	type = "item-with-entity-data",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/drone.png",
	icon_size = 64,
	subgroup = "transport",
	order = "u-b["..name.."]",
	stack_size = 50,
	place_result = name
}

local carrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"motor",4},
		{"alclad-aluminium-sheet",10},
		{"radio-control-unit",1},
		{"ai-limiter",2},
		{"portable-miner",1}
	},
	result = name
}

data:extend{drone, leg, drone_item, speed_sticker, carrecipe}
