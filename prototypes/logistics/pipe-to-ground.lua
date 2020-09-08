-- flow rate calculated as 300/min over 20 pipes
local pipe = data.raw['pipe-to-ground']['pipe-to-ground']
local box = pipe.fluid_box

box.height = 0.0065
box.base_area = 0.01/box.height
-- nerf underground length to reduce pipeline "cheese" (possibly implement as reduced flow / increased area?)
box.pipe_connections[2].max_underground_distance = 5