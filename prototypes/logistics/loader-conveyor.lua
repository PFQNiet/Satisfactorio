-- an ultra-high-speed conveyor that allows buildings to be connected to belts
local name = "loader-conveyor"
local belt = table.deepcopy(data.raw['transport-belt']['transport-belt'])
belt.name = name
belt.speed = 8/256
belt.animation_speed_coefficient = 0
belt.max_health = 1
belt.next_upgrade = nil
belt.fast_replaceable_group = nil
belt.minable = nil
belt.selection_priority = 30
belt.collision_mask = {"transport-belt-layer"}
belt.flags = {"not-on-map"}
data:extend({belt})
