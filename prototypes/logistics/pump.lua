local pump = data.raw.pump.pump
local box = pump.fluid_box
pump.pumping_speed = 300/60/60 -- 300/minute
box.base_area = 0.02/box.height -- capacity = 2m^3
