return {
	type = "tips-and-tricks-item",
	name = "smart-fast-transfer",
	order = "g[smart-fast-transfer]",
	tag = "[item=truck-station]",
	trigger = {
		type = "or",
		triggers = {
			{
				type = "build-entity",
				entity = "truck-station"
			},
			{
				type = "build-entity",
				entity = "drone-port"
			}
		}
	},
	simulation = {
		init = tipTrickSetup{
			player = {
				position = {0,5.5},
				direction = defines.direction.north,
				use_cursor = true
			},
			altmode = true,
			setup = [[
				local surface = game.surfaces[1]
				local station = surface.create_entity{
					name = "truck-station",
					position = {0.5,0},
					force = "player"
				}
				local store = surface.create_entity{
					name = "truck-station-box",
					position = {1.5,-0.5},
					force = "player"
				}
				local fuel = surface.create_entity{
					name = "truck-station-fuelbox",
					position = {-3.5,2.5},
					force = "player"
				}
				surface.create_entity{
					name = "power-pole-mk-3",
					position = {7,0},
					force = "player"
				}
				surface.create_entity{
					name = "power-pole-mk-3",
					position = {7,15},
					force = "player"
				}
				surface.create_entity{
					name = "electric-energy-interface",
					position = {9,15},
					force = "player"
				}

				function fake_transfer_to(entity)
					local stack = player.cursor_stack
					if not (stack.valid and stack.valid_for_read) then return end
					local name, count = stack.name, stack.count
					local inserted = entity.insert{name = name, count = count}
					if inserted == 0 then return end

					player.remove_item{name = name, count = inserted}
					player.surface.create_entity{
						name = "flying-text",
						position = {entity.position.x, entity.position.y - 0.5},
						text = {"", "-",inserted," ",game.item_prototypes[name].localised_name," (",player.get_item_count(name),")"}
					}
					player.play_sound{path = "utility/inventory_move"}
				end

				fake_transfer_from = function(entity)
					local contents = entity.get_output_inventory().get_contents()
					local transferred = {}
					for name, count in pairs (contents) do
						local inserted = player.insert{name = name, count = count}
						if inserted > 0 then
							entity.remove_item{name = name, count = inserted}
							transferred[name] = inserted
						end
					end

					local line_number = 0
					for name,count in pairs(transferred) do
						if line_number == 0 then
							player.play_sound{ path = "utility/inventory_move" }
						end
						player.surface.create_entity{
							name = "flying-text",
							position = {entity.position.x, entity.position.y - 0.5 + 0.5*line_number},
							text = {"", "+", count, " ", game.item_prototypes[name].localised_name, " (", player.get_item_count(name), ")"}
						}
						line_number = line_number + 1
					end
				end
			]],
			sequence = {
				{ -- reset inventories
					setup = [[
						store.clear_items_inside()
						fuel.clear_items_inside()
						player.clear_items_inside()
						player.insert{name="coal",count=250}
						player.insert{name="reinforced-iron-plate",count=250}
						local count = 60
					]],
					update = "count = count-1",
					proceed = "count <= 0"
				},
				{ -- put RIPs in cursor and move cursor to truck station
					setup = [[
						local stack = player.get_main_inventory().find_item_stack("reinforced-iron-plate")
						stack.swap_stack(player.cursor_stack)
					]],
					update = "",
					proceed = "game.move_cursor{position=station.position}"
				},
				{ -- fast-transfer until cursor empty
					setup = "local cooldown = 60",
					update = [[
						cooldown = cooldown - 1
						if cooldown <= 0 then
							if player.cursor_stack.valid_for_read then
								fake_transfer_to(store)
								cooldown = 60
							end
						end
					]],
					proceed = "cooldown <= 0 and game.move_cursor{position=player.character.position}"
				},
				{ -- put coal in cursor
					setup = "local count = 60",
					update = [[
						if count == 30 then
							local stack = player.get_main_inventory().find_item_stack("coal")
							stack.swap_stack(player.cursor_stack)
						end
						count = count - 1
					]],
					proceed = "count <= 0 and game.move_cursor{position=station.position}"
				},
				{ -- fast-transfer coal to fuel box, then to cargo until empty
					setup = [[
						local cooldown = 60
						local first = true
					]],
					update = [[
						cooldown = cooldown - 1
						if cooldown <= 0 then
							if player.cursor_stack.valid_for_read then
								fake_transfer_to(first and fuel or store)
								first = false
								cooldown = 60
							end
						end
					]],
					proceed = "cooldown <= 0 and game.move_cursor{position=player.character.position}"
				},
				{ -- then back to station one more time to transfer things back
					setup = "local count = 60",
					update = "count = count - 1",
					proceed = "count <= 0 and game.move_cursor{position=station.position}"
				},
				{ -- transfer items from the cargo, then from the fuel box
					setup = "local count = 240",
					update = [[
						count = count - 1
						if count == 210 then
							fake_transfer_from(store)
						elseif count == 90 then
							fake_transfer_from(fuel)
						end
					]],
					proceed = "count <= 0 and game.move_cursor{position=player.character.position}"
				}
			}
		}
	}
}
