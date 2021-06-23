local bufferbox = {
	type = "container",
	name = "miner-box",
	collision_box = {{-1.5,-1.5},{1.5,1.5}},
	collision_mask = {},
	enable_inventory_bar = false,
	flags = {"not-on-map"},
	icon = "__base__/graphics/icons/wooden-chest.png",
	icon_mipmaps = 4,
	icon_size = 64,
	inventory_size = 1,
	max_health = 1,
	picture = empty_graphic,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	selectable_in_game = false
}
data:extend{bufferbox}

local function makeMiner(params)
	---@type string
	local name = params.name
	---@type int
	local power = params.power
	---@type int 1, 2, 4
	local speed = params.speed
	---@type string
	local order = params.order
	---@type table
	local ingredients = params.ingredients

	local sounds = copySoundsFrom(data.raw["mining-drill"]["electric-mining-drill"])
	local miner = {
		type = "mining-drill",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		animations = makeRotatedSprite(name, 160, 288, {0,-2}),
		selection_box = {{-2.5,-6.5},{2.5,2.5}},
		collision_box = {{-2.2,-6.2},{2.2,2.2}},
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage = power.."MW",
		open_sound = sounds.open_sound,
		close_sound = sounds.close_sound,
		working_sound = sounds.working_sound,
		flags = {
			"placeable-player",
			"player-creation"
		},
		max_health = 1,
		minable = {
			mining_time = 0.5,
			result = name
		},
		mining_speed = speed/2, -- base 30/min
		resource_categories = {"solid"},
		resource_searching_radius = 1.49,
		allowed_effects = {"speed","consumption"},
		module_specification = {module_slots = 3},
		fast_replaceable_group = "miner",
		vector_to_place_result = {0,0}
	}

	local mineritem = {
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		place_result = name,
		stack_size = 50,
		subgroup = "production-miner",
		order = "c[mining-drill]-"..order.."["..name.."]"
	}

	local minerrecipe = makeBuildingRecipe{
		name = name,
		ingredients = ingredients,
		result = name
	}

	data:extend{miner,mineritem,minerrecipe}
end

makeMiner{
	name = "miner-mk-1",
	power = 5,
	speed = 1,
	order = "a",
	ingredients = {
		{"portable-miner",1},
		{"iron-plate",10},
		{"concrete",10}
	}
}

makeMiner{
	name = "miner-mk-2",
	power = 12,
	speed = 2,
	order = "b",
	ingredients = {
		{"portable-miner",2},
		{"encased-industrial-beam",10},
		{"steel-pipe",20},
		{"modular-frame",10}
	}
}

makeMiner{
	name = "miner-mk-3",
	power = 30,
	speed = 4,
	order = "c",
	ingredients = {
		{"portable-miner",3},
		{"steel-pipe",50},
		{"supercomputer",5},
		{"fused-modular-frame",10},
		{"turbo-motor",3}
	}
}
