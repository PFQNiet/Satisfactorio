-- an ultra-high-speed conveyor that allows buildings to be connected to belts
local name = "loader-conveyor"
local belt = table.deepcopy(data.raw['transport-belt']['transport-belt'])
belt.name = name
belt.speed = 1
belt.max_health = 1
belt.next_upgrade = nil
belt.fast_replaceable_group = nil
belt.minable = nil
data:extend({belt})