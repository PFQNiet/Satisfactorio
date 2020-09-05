-- flow rate calculated as 300/min over 20 pipes
local pipe = data.raw.pipe.pipe
local box = pipe.fluid_box
box.height = 0.0065
box.base_area = 0.01/box.height
