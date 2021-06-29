return {
	type = "tips-and-tricks-item",
	name = "conveyor-belts",
	order = "e[conveyor-belts]",
	tag = "[item=conveyor-belt-mk-1]",
	trigger = {
		type = "research",
		technology = "hub-tier0-hub-upgrade4"
	},
	simulation = {
		init = tipTrickSetup{
			use_io = true,
			altmode = true,
			player = {
				position = {0,4},
				direction = defines.direction.north,
				use_cursor = true
			},
			setup = [[
				local surface = game.surfaces[1]
				local north = defines.direction.north
				local east = defines.direction.east
				local south = defines.direction.south
				local west = defines.direction.west
				local names = {
					belt = "conveyor-belt-mk-1",
					storage = "storage-container-placeholder",
					storebox = "infinity-storage-container",
					smelter = "smelter",
					constructor = "constructor",
					powerpole = "power-pole-mk-2",
					eei = "electric-energy-interface",
					ore = "iron-ore",
					ingot = "iron-ingot",
					plate = "iron-plate"
				}
				-- createLoader(position, direction, tier, entity, mode)

				surface.create_entity{name=names.storage, position={-10.5,0.5}, direction=east, force="player"}
				local buffer1 = surface.create_entity{name=names.storebox, position={-10.5,0.5}, force="player"}
				-- omg it's secretly an infinity box! In disguise!
				buffer1.set_infinity_container_filter(1, {index=1, name="iron-ore", count=100, mode="at-least"})
				local smelter = surface.create_entity{name=names.smelter, position={-3.5,0.5}, direction=east, force="player", recipe=names.ingot}
				local constructor = surface.create_entity{name=names.constructor, position={3.5,0.5}, direction=east, force="player", recipe=names.plate}
				surface.create_entity{name=names.storage, position={10.5,0.5}, direction=east, force="player"}
				local buffer2 = surface.create_entity{name=names.storebox, position={10.5,0.5}, force="player"}
				buffer2.remove_unfiltered_items = true

				-- fake loaders for graphics
				createLoader({-12.5,0.5}, east, 0, buffer1, "input")
				createLoader({-8.5,0.5}, east, 0, buffer1, "output")
				createLoader({-5.5,0.5}, east, 0, smelter, "input")
				createLoader({-1.5,0.5}, east, 0, smelter, "output")
				createLoader({1.5,0.5}, east, 0, constructor, "input")
				createLoader({5.5,0.5}, east, 0, constructor, "output")
				createLoader({8.5,0.5}, east, 0, buffer2, "input")
				createLoader({12.5,0.5}, east, 0, buffer2, "output")

				surface.create_entity{name=names.powerpole, position={3.5,-1.5}, force="player"}
				surface.create_entity{name=names.powerpole, position={-3.5,-1.5}, force="player"}
				surface.create_entity{name=names.powerpole, position={-3.5,-9.5}, force="player"}
				surface.create_entity{name=names.eei, position={-3,-12}, force="player"}
			]],
			sequence = {
				{ -- reset all items
					setup = [[
						for _,e in pairs(surface.find_entities_filtered{name={names.belt, "loader-conveyor-belt-mk-1", "loader-inserter"}}) do
							e.destroy()
						end
						smelter.crafting_progress = 0
						smelter.clear_items_inside()
						constructor.crafting_progress = 0
						constructor.clear_items_inside()
						local count = 120
					]],
					update = [[
						count = count - 1
						if count == 30 then
							player.cursor_stack.set_stack{name="conveyor-belt-mk-1", count=50}
							game.camera_player_cursor_direction = east

							smelter.insert{name=names.ore, count=6}
							smelter.get_output_inventory().insert{name=names.ingot, count=1}
							constructor.insert{name=names.ingot, count=12}
							constructor.get_output_inventory().insert{name=names.plate, count=2}
						end
					]],
					proceed = "count <= 0 and game.move_cursor{position={-7.5,0.5}}"
				},
				{ -- slide cursor to the right, connecting the buildings as appropriate
					setup = [[
						local belt_number = 0
						local target_x = -6.5
					]],
					update = [[
						local arrived = game.move_cursor{position={target_x,0.5}}
						if arrived then
							target_x = target_x + 1
						end
						if player.can_build_from_cursor{position=game.camera_player_cursor_position, direction=east} then
							player.build_from_cursor{position=game.camera_player_cursor_position, direction=east, force="player"}
							belt_number = belt_number + 1
							local loader
							if belt_number == 1 then
								loader = createLoader({-8.5,0.5}, east, 1, buffer1, "output")
							elseif belt_number == 2 then
								loader = createLoader({-5.5,0.5}, east, 1, smelter, "input")
							elseif belt_number == 3 then
								loader = createLoader({-1.5,0.5}, east, 1, smelter, "output")
							elseif belt_number == 4 then
								loader = createLoader({1.5,0.5}, east, 1, constructor, "input")
							elseif belt_number == 5 then
								loader = createLoader({5.5,0.5}, east, 1, constructor, "output")
							elseif belt_number == 6 then
								loader = createLoader({8.5,0.5}, east, 1, buffer2, "input")
							end
							if loader then
								-- graphics are already in place
								rendering.destroy(loader.visual)
							end
						end
					]],
					proceed = "arrived and target_x > 7.5"
				},
				{ -- wait a moment, then clear the cursor and return to starting position
					setup = "count = 120",
					update = [[
						count = count - 1
						if count == 30 then
							player.clear_cursor()
						end
					]],
					proceed = "count <= 0 and game.move_cursor{position=player.character.position}"
				},
				{ -- wait a little longer before looping
					setup = "count = 600",
					update = "count = count - 1",
					proceed = "count <= 0"
				}
			}
		}
	}
}
