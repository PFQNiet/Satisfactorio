pipe_height_1 = 0.0065 -- produces a flow rate of 300/min over 20 pipes
pipe_height_2 = 0.0093 -- produces a flow rate of 600/min over 50 pipes

local function makePipe(params)
	---@type string
	local name = params.name
	---@type number
	local height = params.fluid_box_height
	---@type string
	local order = params.order
	---@type table
	local tint = params.tint
	---@type table
	local ingredients = params.ingredients

	local pipe = table.deepcopy(data.raw.pipe.pipe)
	pipe.name = name
	pipe.minable.result = name
	pipe.icon = graphics.."icons/"..name..".png"
	pipe.icon_size = 64
	pipe.icon_mipmaps = 0
	local box = pipe.fluid_box
	box.height = height
	box.base_area = 0.01/box.height
	if tint then
		local pics_to_tint = {
			"straight_vertical_single",
			"straight_vertical", "straight_vertical_window",
			"straight_horizontal", "straight_horizontal_window",
			"corner_up_right", "corner_up_left", "corner_down_right", "corner_down_left",
			"t_up", "t_down", "t_right", "t_left",
			"cross",
			"ending_up", "ending_down", "ending_right", "ending_left"
		}
		for _,key in pairs(pics_to_tint) do
			local pic = pipe.pictures[key]
			pic.tint = tint
			if pic.hr_version then
				pic.hr_version.tint = tint
			end
		end
	end

	local pipeitem = {
		type = "item",
		name = name,
		place_result = name,
		icon = pipe.icon,
		icon_size = 64,
		stack_size = 50,
		subgroup = "pipe-distribution",
		order = "a["..pipe.type.."]-"..order.."["..name.."]"
	}

	local piperecipe = makeBuildingRecipe{
		name = name,
		ingredients = ingredients,
		result = name
	}

	data:extend{pipe,pipeitem,piperecipe}
end

makePipe{
	name = "pipeline",
	fluid_box_height = pipe_height_1,
	order = "a",
	ingredients = {{"copper-sheet",1}}
}
makePipe{
	name = "pipeline-mk-2",
	fluid_box_height = pipe_height_2,
	order = "b",
	tint = {0.2,0.8,1},
	ingredients = {{"copper-sheet",2},{"plastic",1}}
}

local function makeUndergroundPipe(params)
	---@type string
	local name = params.name
	---@type number
	local height = params.fluid_box_height
	---@type int
	local length = params.underground_length
	---@type string
	local order = params.order
	---@type table
	local tint = params.tint
	---@type table
	local ingredients = params.ingredients

	local pipe = table.deepcopy(data.raw["pipe-to-ground"]["pipe-to-ground"])
	pipe.name = name
	pipe.minable.result = name
	pipe.icon = graphics.."icons/"..name..".png"
	pipe.icon_size = 64
	pipe.icon_mipmaps = 0
	local box = pipe.fluid_box
	box.height = height
	box.base_area = 0.01/box.height
	box.pipe_connections[2].max_underground_distance = length
	for _,pic in pairs(pipe.pictures) do
		pic.tint = tint
		if pic.hr_version then
			pic.hr_version.tint = tint
		end
	end

	local pipeitem = {
		type = "item",
		name = name,
		place_result = name,
		icon = pipe.icon,
		icon_size = 64,
		stack_size = 50,
		subgroup = "pipe-distribution",
		order = "b["..pipe.type.."]-"..order.."["..name.."]"
	}

	local piperecipe = makeBuildingRecipe{
		name = name,
		ingredients = ingredients,
		result = name
	}

	data:extend{pipe,pipeitem,piperecipe}
end

makeUndergroundPipe{
	name = "underground-pipeline",
	fluid_box_height = pipe_height_1,
	underground_length = 5,
	order = "a",
	ingredients = {{"copper-sheet",4}}
}
makeUndergroundPipe{
	name = "underground-pipeline-mk-2",
	fluid_box_height = pipe_height_2,
	underground_length = 7,
	order = "b",
	tint = {0.2,0.8,1},
	ingredients = {{"copper-sheet",8},{"plastic",4}}
}

local function makePump(params)
	---@type string
	local name = params.name
	---@type number fluid per minute
	local speed = params.pump_speed
	---@type int MW
	local power = params.power
	---@type string
	local order = params.order
	---@type table
	local tint = params.tint
	---@type table
	local ingredients = params.ingredients

	local pump = table.deepcopy(data.raw.pump.pump)
	pump.name = name
	pump.minable.result = name
	pump.icon = graphics.."icons/"..name..".png"
	pump.icon_size = 64
	pump.icon_mipmaps = 0
	pump.pumping_speed = speed/60/60
	pump.max_health = 1
	local box = pump.fluid_box
	box.base_area = 0.02/box.height -- capacity = 2m^3
	pump.energy_source.drain = "0W"
	pump.energy_usage = power.."MW"
	if tint then
		for _,pic in pairs(pump.animations) do
			pic.tint = tint
			if pic.hr_version then
				pic.hr_version.tint = tint
			end
		end
	end

	local pumpitem = {
		type = "item",
		name = name,
		place_result = name,
		icon = pump.icon,
		icon_size = 64,
		stack_size = 50,
		subgroup = "pipe-distribution",
		order = "c["..pump.type.."]-"..order.."["..name.."]"
	}

	local pumprecipe = makeBuildingRecipe{
		name = name,
		ingredients = ingredients,
		result = name
	}

	data:extend{pump, pumpitem, pumprecipe}
end

makePump{
	name = "pipeline-pump",
	pump_speed = 300,
	power = 4,
	order = "a",
	ingredients = {
		{"copper-sheet",2},
		{"rotor",2}
	}
}
makePump{
	name = "pipeline-pump-mk-2",
	pump_speed = 600,
	power = 8,
	order = "b",
	tint = {0.2,0.8,1},
	ingredients = {
		{"motor",2},
		{"encased-industrial-beam",4},
		{"plastic",8}
	}
}
