require("prototypes.resource-scanner.scanner-iron-ore")
require("prototypes.resource-scanner.scanner-copper-ore")
require("prototypes.resource-scanner.scanner-stone")
require("prototypes.resource-scanner.scanner-coal")
require("prototypes.resource-scanner.scanner-crude-oil")
require("prototypes.resource-scanner.scanner-caterium-ore")
require("prototypes.resource-scanner.scanner-bauxite")
require("prototypes.resource-scanner.scanner-raw-quartz")
require("prototypes.resource-scanner.scanner-uranium-ore")
require("prototypes.resource-scanner.scanner-sulfur")
require("prototypes.resource-scanner.scanner-geyser")

require("prototypes.resource-scanner.scanner-map-marker")
require("prototypes.resource-scanner.scanner-beryl-nut")
require("prototypes.resource-scanner.scanner-paleberry")
require("prototypes.resource-scanner.scanner-bacon-agaric")
require("prototypes.resource-scanner.scanner-power-slugs")
require("prototypes.resource-scanner.scanner-crash-site")
require("prototypes.resource-scanner.scanner-enemies")

data:extend({
	{
		type = "custom-input",
		name = "resource-scanner",
		key_sequence = "V",
		order = "b",
		consuming = "game-only",
		action = "lua"
	},
	{
		type = "shortcut",
		name = "resource-scanner",
		action = "lua",
		associated_control_input = "resource-scanner",
		icon = {
			filename = "__Satisfactorio__/graphics/icons/resource-scanner.png",
			size = 64
		},
		disabled_icon = {
			filename = "__Satisfactorio__/graphics/icons/resource-scanner-white.png",
			size = 64
		},
		order = "s-b[resource-scanner]"
	},
	{ -- dummy entity so that "made in..." shows correctly for resource-scanner recipes
		animation = {
			filename = "__Satisfactorio__/graphics/icons/resource-scanner.png",
			size = {64,64}
		},
		collision_box = {{-0.7,-0.7},{0.7,0.7}},
		corpse = "big-remnants",
		crafting_categories = {"resource-scanner"},
		crafting_speed = 1,
		dying_explosion = "big-explosion",
		energy_source = {type="void"},
		energy_usage = "1W",
		flags = {},
		fluid_boxes = {{production_type="output",pipe_connections={{position={0,-1.5},type="output"}}}},
		icon = "__Satisfactorio__/graphics/icons/resource-scanner-white.png",
		icon_size = 64,
		max_health = 1,
		minable = nil,
		name = "resource-scanner",
		selection_box = {{-1,-1},{1,1}},
		type = "assembling-machine"
	},
	{ -- dummy entity so that "made in..." shows correctly for object-scanner recipes
		animation = {
			filename = "__Satisfactorio__/graphics/icons/object-scanner.png",
			size = {64,64}
		},
		collision_box = {{-0.7,-0.7},{0.7,0.7}},
		corpse = "big-remnants",
		crafting_categories = {"object-scanner"},
		crafting_speed = 1,
		dying_explosion = "big-explosion",
		energy_source = {type="void"},
		energy_usage = "1W",
		flags = {},
		fluid_boxes = {{production_type="output",pipe_connections={{position={0,-1.5},type="output"}}}},
		icon = "__Satisfactorio__/graphics/icons/object-scanner.png",
		icon_size = 64,
		max_health = 1,
		minable = nil,
		name = "object-scanner",
		selection_box = {{-1,-1},{1,1}},
		type = "assembling-machine"
	},
	{ -- scanner pulse
		type = "trivial-smoke",
		name = "resource-scanner-pulse",
		animation = {
			filename = "__Satisfactorio__/graphics/particles/resource-scanner-pulse.png",
			size = 64,
			blend_mode = "additive-soft",
			flags = {"trilinear-filtering"}
		},
		duration = 120,
		affected_by_wind = false,
		color = {r=0.2,g=0.8,b=1,a=1},
		cyclic = true,
		start_scale = 0.1,
		end_scale = 100,
		movement_slow_down_factor = 1,
		spread_duration = 120,
		fade_away_duration = 30
	},
	{
		type = "sprite",
		name = "resource-scanner-ping",
		filename = "__Satisfactorio__/graphics/particles/resource-scanner-ping.png",
		size = 64
	}
})
