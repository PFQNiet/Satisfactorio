-- an ultra-high-speed conveyor that allows buildings to be connected to belts
local name = "loader-conveyor"
local belt = table.deepcopy(data.raw['transport-belt']['transport-belt'])
belt.name = name
belt.localised_name = {"entity-name.machine-io"}
belt.speed = 8/256
belt.animation_speed_coefficient = 0
belt.max_health = 1
belt.next_upgrade = nil
belt.fast_replaceable_group = "loader-belt"
belt.minable = {mining_time=60}
belt.selectable_in_game = false
belt.collision_mask = {"transport-belt-layer"}
belt.flags = {"not-on-map"}
belt.related_underground_belt = nil
belt.icon = "__base__/graphics/icons/inserter.png"
local anim = belt.belt_animation_set.animation_set
anim.filename = graphics.."empty.png"
anim.width = 1
anim.height = 1
anim.frame_count = 1
belt.belt_animation_set.animation_set.hr_version = nil
data:extend{belt}

-- create duplicate belt types for existing types
for i=1,5 do
	local belt = table.deepcopy(data.raw['transport-belt']['conveyor-belt-mk-'..i])
	belt.localised_name = {"entity-name."..belt.name}
	belt.name = "loader-"..belt.name
	belt.next_upgrade = nil
	belt.fast_replaceable_group = "loader-belt"
	belt.minable = {mining_time=60}
	belt.selectable_in_game = false
	belt.collision_mask = {"transport-belt-layer"}
	belt.flags = {"not-on-map"}
	belt.icons = {
		{icon = belt.icon, icon_size = belt.icon_size},
		{icon = "__base__/graphics/icons/inserter.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}}
	}
	data:extend{belt}
end

-- invisible inserters used to load/unload machines
local inserter = {
	type = "inserter",
	name = "loader-inserter",
	localised_name = {"entity-name.machine-io"},
	icons = {
		{icon = graphics.."icons/constructor.png", icon_size = 64},
		{icon = "__base__/graphics/icons/inserter.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, 8}}
	},
	minable = nil, -- will always be removed by the building that spawned it
	collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
	collision_mask = {},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
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
	max_health = 1,
	pickup_position = {0, -1},
	insert_position = {0, 1.2},
	draw_held_item = false,
	draw_inserter_arrow = false,
	draw_circuit_wires = false,
	platform_picture = empty_graphic,
	hand_base_picture = empty_graphic,
	hand_open_picture = empty_graphic,
	hand_closed_picture = empty_graphic,
	circuit_wire_max_distance = 5
}
data:extend{inserter}
