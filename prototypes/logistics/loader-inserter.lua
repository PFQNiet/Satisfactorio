-- invisible inserters used to load/unload machines
local name = "loader-inserter"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}
local inserter = {
	type = "inserter",
	name = name,
	icon = "__base__/graphics/icons/fast-inserter.png",
	icon_mipmaps = 4,
	icon_size = 64,
	minable = nil, -- will always be removed by the building that spawned it
	collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selection_priority = 30,
	selectable_in_game = false,
	flags = {
		"not-on-map",
		"placeable-off-grid"
	},
	allow_custom_vectors = true,
	energy_per_movement = "1W",
	energy_per_rotation = "1W",
	energy_source = {type="void"},
	extension_speed = 10,
	rotation_speed = 0.5,
	filter_count = 5,
	pickup_position = {0, -1},
	insert_position = {0, 1.2},
	draw_held_item = false,
	draw_inserter_arrow = false,
	draw_circuit_wires = false,
	platform_picture = empty_sprite,
	hand_base_picture = empty_sprite,
	hand_open_picture = empty_sprite,
	hand_closed_picture = empty_sprite,
	circuit_wire_max_distance = 5
}
data:extend({inserter})
