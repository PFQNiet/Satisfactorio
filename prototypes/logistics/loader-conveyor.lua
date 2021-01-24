-- an ultra-high-speed conveyor that allows buildings to be connected to belts
local name = "loader-conveyor"
local belt = table.deepcopy(data.raw['transport-belt']['transport-belt'])
belt.name = name
belt.speed = 8/256
belt.animation_speed_coefficient = 0
belt.max_health = 1
belt.next_upgrade = nil
belt.fast_replaceable_group = "loader-belt"
belt.minable = {mining_time=1}
belt.selectable_in_game = false
belt.collision_mask = {"transport-belt-layer"}
belt.flags = {"not-on-map"}
local anim = belt.belt_animation_set.animation_set
anim.filename = "__Satisfactorio__/graphics/empty.png"
anim.width = 1
anim.height = 1
anim.frame_count = 1
belt.belt_animation_set.animation_set.hr_version = nil
data:extend({belt})

-- create duplicate belt types for existing types
for _,name in pairs({"","fast-","express-","turbo-","ultimate-"}) do
	local belt = table.deepcopy(data.raw['transport-belt'][name..'transport-belt'])
	belt.name = "loader-"..belt.name
	belt.next_upgrade = nil
	belt.fast_replaceable_group = "loader-belt"
	belt.minable = {mining_time=1}
	belt.selectable_in_game = false
	belt.collision_mask = {"transport-belt-layer"}
	belt.flags = {"not-on-map"}
	data:extend{belt}
end
