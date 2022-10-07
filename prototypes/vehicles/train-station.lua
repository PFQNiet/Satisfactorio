local placeholder = require("graphics.placeholders.builder")

-- base entity is an electric-energy-interface to manage power consumption
-- station is 7x14 and auto-builds (and removes) a vanilla train-stop entity
-- freight platform layout is |OI-IO|
-- fluid platform consists of pumps and a storage tank, so that it can draw fluid into itself and output it
-- central 7x2 is reserved for the rails
train_platform_layer = require("collision-mask-util").get_first_unused_layer()

local name = "train-station"

local stop = data.raw.item['train-stop']
stop.localised_name = {"entity-name."..name}
stop.place_result = nil
if not stop.flags then stop.flags = {} end
table.insert(stop.flags, "hidden")
stop = data.raw['train-stop']['train-stop']
-- stop.flags = {"placeable-neutral", "filter-directions"} -- not a "player-creation"
stop.collision_mask = {}
stop.minable = nil
stop.max_health = 1
stop.selectable_in_game = false

local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "50MW",
		usage_priority = "secondary-input",
		drain = "0W",
		output_flow_limit = "0W"
	},
	energy_usage = "50MW", -- initial value, which gets increased when pulling trains
	pictures = placeholder().fourway().addBox(-6.5,-3,6,7,{},{}).addBox(1.5,-3,6,7,{},{}).addIcon(graphics.."icons/"..name..".png",64,{4,0}).result(),
	max_health = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	render_layer = "decorative", -- required so that the train-stop renders on top of it
	collision_box = {{-6.7,-3.2},{6.7,3.2}},
	collision_mask = {train_platform_layer},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	remove_decoratives = "true",
	open_sound = stop.open_sound,
	close_sound = stop.close_sound,
	selection_box = {{-7,-3.5},{7,3.5}},
	selection_priority = 49
}

local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[train-system]-b[platforms]-a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "train-transport",
	type = "item"
}

local recipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"heavy-modular-frame",4},
		{"computer",8},
		{"concrete",50},
		{"copper-cable",25}
	},
	result = name
}

data:extend{base,item,recipe}
