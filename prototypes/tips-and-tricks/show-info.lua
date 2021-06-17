local tip = data.raw['tips-and-tricks-item']['show-info']
tip.simulation = {
	init = tiptrickutils..[[
		game.camera_position = {0,0}
		game.camera_zoom = 1
		game.surfaces[1].create_entity{name = "miner-mk-1", position = {-6.5, -2.5}, direction = defines.direction.east, force = "player"}

		local chest = game.surfaces[1].create_entity{name = "iron-chest", position = {4.5, -2.5}, force = "player"}
		local inventory = chest.get_inventory(defines.inventory.chest)
		inventory.insert{name = "iron-plate", count = 100}
		inventory.insert{name = "iron-gear-wheel", count = 100}
		inventory.insert{name = "electronic-circuit", count = 100}
		game.surfaces[1].create_entity{name = "storage-container-placeholder", position = {4.5, -2.5}, direction = defines.direction.east, force = "player"}

		local pipe = game.surfaces[1].create_entity{name = "pipe", position = {4.5, 3.5}, force = "player"}
		pipe.insert_fluid{name = "water", amount = 1}
		game.surfaces[1].create_entity{name = "pipe-to-ground", position = {4.5, 2.5}, force = "player", direction = defines.direction.south}
		game.surfaces[1].create_entity{name = "pipe-to-ground", position = {5.5, 3.5}, force = "player", direction = defines.direction.west}

		game.surfaces[1].create_entity{name = "coal-generator", position = {-3, 3.5}, direction = defines.direction.west, force = "player"}

		io.generate(game.surfaces[1])
	]],
	update = [[
		game.camera_alt_info = (game.tick % 120) < 60
	]]
}
