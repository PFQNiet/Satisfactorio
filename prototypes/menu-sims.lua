-- menu sim map seed: 2658861361

local path = modname.."/menu-simulations/satis-demo-"
local find_logo = [[
	local logo = game.surfaces.nauvis.find_entities_filtered{name="factorio-logo-11tiles",limit=1}[1]
	game.camera_position = {logo.position.x, logo.position.y+9.75}
	game.camera_zoom = 1
	game.tick_paused = false
	game.surfaces.nauvis.daytime = 0
]]
data.raw['utility-constants'].default.main_menu_simulations = {
	refinery = {
		checkboard = false,
		save = path.."refinery.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	},
	coal_power = {
		checkboard = false,
		save = path.."coal-power.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	},
	self_driving = {
		checkboard = false,
		save = path.."self-driving.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	},
	space_elevator = {
		checkboard = false,
		save = path.."space-elevator.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	},
	drones = {
		checkboard = false,
		save = path.."drones.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	},
	smart_splitter = {
		checkboard = false,
		save = path.."smart-splitters.zip",
		length = 30 * 60,
		init = find_logo,
		update = [[]]
	}
}
