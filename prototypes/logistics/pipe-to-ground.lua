-- flow rate calculated as 300/min over 20 pipes
data.raw['pipe-to-ground']['pipe-to-ground'].fluid_box.height = 0.0065
data.raw['pipe-to-ground']['pipe-to-ground'].fluid_box.base_area = 0.01/data.raw['pipe-to-ground']['pipe-to-ground'].fluid_box.height
-- nerf underground length to reduce pipeline "cheese" (possibly implement as reduced flow / increased area?)
data.raw['pipe-to-ground']['pipe-to-ground'].fluid_box.pipe_connections[2].max_underground_distance = 5
