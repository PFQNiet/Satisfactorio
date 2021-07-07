return {
	type = "tips-and-tricks-item",
	name = "train-loading",
	order = "h[smart-fast-transfer]",
	tag = "[item=train-station]",
	trigger = {
		type = "build-entity",
		entity = "train-station"
	},
	simulation = {
		init = tipTrickSetup{
			use_io = true,
			altmode = true,
			player = {
				position = {3.5,1.5},
				direction = defines.direction.north,
				use_cursor = true
			},
			setup = [[
				local surface = game.surfaces[1]
				local item = "encased-industrial-beam"
				local station = surface.create_entity{
					name = "train-station",
					position = {4.5,-1},
					direction = defines.direction.east,
					force = "player"
				}
				local stop = surface.create_entity{
					name = "train-stop",
					position = {7,1},
					direction = defines.direction.east,
					force = "player"
				}
				local platform = surface.create_entity{
					name = "freight-platform",
					position = {-2.5,-1},
					direction = defines.direction.east,
					force = "player"
				}
				local cargo = surface.create_entity{
					name = "freight-platform-box",
					position = {-2.5,2.5},
					force = "player"
				}
				local cargo_inventory = cargo.get_inventory(defines.inventory.chest)
				local unloader = createLoader({-0.5,5.5}, defines.direction.south, 4, cargo, "output")
				createLoader({-1.5,5.5}, defines.direction.north, 0, cargo, "input")
				createLoader({-3.5,5.5}, defines.direction.north, 0, cargo, "input")
				createLoader({-4.5,5.5}, defines.direction.south, 0, cargo, "output")
				for i=1,2 do
					local line = unloader.belt.get_transport_line(i)
					for o=0,3 do
						line.insert_at(o/4, {name=item})
					end
				end
				
				for y=6.5,10.5,1 do
					local belt = surface.create_entity{
						name = "conveyor-belt-mk-4",
						position = {-0.5,y},
						direction = defines.direction.south,
						force = "player"
					}
					for i=1,2 do
						local line = belt.get_transport_line(i)
						for o=0,3 do
							line.insert_at(o/4, {name=item})
						end
					end
				end
				surface.create_entity{
					name = "infinity-storage-container-placeholder",
					position = {-0.5,13.5},
					direction = defines.direction.south,
					force = "player"
				}
				local deleter = surface.create_entity{
					name = "infinity-storage-container",
					position = {-0.5,13.5},
					force = "player"
				}
				deleter.remove_unfiltered_items = true
				createLoader({-0.5,11.5}, defines.direction.south, 4, deleter, "input")

				for x=-19,19,2 do
					surface.create_entity{
						name = "straight-rail",
						position = {x,-1},
						direction = defines.direction.east,
						force = "player"
					}
					surface.create_entity{
						name = "straight-rail",
						position = {x,21},
						direction = defines.direction.east,
						force = "player"
					}
				end
				surface.create_entity{
					name = "curved-rail",
					position = {24,0},
					direction = defines.direction.southeast,
					force = "player"
				}
				surface.create_entity{
					name = "straight-rail",
					position = {27,3},
					direction = defines.direction.northeast,
					force = "player"
				}
				surface.create_entity{
					name = "curved-rail",
					position = {30,6},
					direction = defines.direction.north,
					force = "player"
				}
				surface.create_entity{
					name = "curved-rail",
					position = {30,14},
					direction = defines.direction.southwest,
					force = "player"
				}
				surface.create_entity{
					name = "straight-rail",
					position = {27,17},
					direction = defines.direction.southeast,
					force = "player"
				}
				surface.create_entity{
					name = "curved-rail",
					position = {24,20},
					direction = defines.direction.east,
					force = "player"
				}
				surface.create_entity{
					name = "curved-rail",
					position = {-24,20},
					direction = defines.direction.northwest,
					force = "player"
				}
				surface.create_entity{
					name = "straight-rail",
					position = {-27,17},
					direction = defines.direction.southwest,
					force = "player"
				}
				surface.create_entity{
					name = "curved-rail",
					position = {-30,14},
					direction = defines.direction.south,
					force = "player"
				}
				surface.create_entity{
					name = "curved-rail",
					position = {-30,6},
					direction = defines.direction.northeast,
					force = "player"
				}
				surface.create_entity{
					name = "straight-rail",
					position = {-27,3},
					direction = defines.direction.northwest,
					force = "player"
				}
				surface.create_entity{
					name = "curved-rail",
					position = {-24,0},
					direction = defines.direction.west,
					force = "player"
				}

				local otherstop = surface.create_entity{
					name = "train-stop",
					position = {-7,19},
					direction = defines.direction.west,
					force = "player"
				}

				surface.create_entity{
					name = "power-pole-mk-2",
					position = {0.5,-10.5},
					force = "player"
				}
				surface.create_entity{
					name = "power-pole-mk-2",
					position = {0.5,-15.5},
					force = "player"
				}
				surface.create_entity{
					name = "electric-energy-interface",
					position = {3,-15},
					force = "player"
				}

				loco = surface.create_entity{
					name = "locomotive",
					position = {-16,21},
					direction = defines.direction.west,
					force = "player"
				}
				local wagon = surface.create_entity{
					name = "cargo-wagon",
					position = {-11,21},
					direction = defines.direction.west,
					force = "player"
				}
				local wagon_inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
				loco.connect_rolling_stock(defines.rail_direction.back)
				local train = loco.train
				train.schedule = {
					current = 1,
					records = {
						{
							station = stop.backer_name,
							wait_conditions = {{
								type = "empty",
								compare_type = "and"
							}}
						},
						{
							station = otherstop.backer_name,
							wait_conditions = {}
						},
						{
							station = stop.backer_name,
							wait_conditions = {{
								type = "empty",
								compare_type = "and"
							}}
						}
					}
				}
				train.manual_mode = false
				loco.burner.currently_burning = "train-power"

				local stack_transfer_timer = 0
				cargo_inventory.insert{name=item, count=200}

				local text = rendering.draw_text{
					text = "",
					color = {1,1,1},
					surface = surface,
					target = cargo,
					target_offset = {1.5,1.5},
					alignment = "right",
					vertical_alignment = "baseline"
				}
				local is_full = false
				rendering.draw_text{
					text = {"tips-and-tricks-extra-text.train-unloading-accelerated"},
					color = {1,1,1},
					font = "default-game",
					surface = surface,
					target = {-15.5,9},
					alignment = "left",
					vertical_alignment = "bottom"
				}

				script.on_event(defines.events.on_train_changed_state, function(event)
					if event.tick == 0 then return end
					if event.train.state == defines.train_state.arrive_station then
						wagon_inventory.insert{name=item, count=3200}
					elseif event.train.state == defines.train_state.wait_station then
						unloader.inserter_left.active = false
						unloader.inserter_right.active = false
					elseif event.train.state == defines.train_state.on_the_path then
						unloader.inserter_left.active = true
						unloader.inserter_right.active = true
					end
				end)
			]],
			update = [[
				-- keep train fuelled
				loco.burner.remaining_burning_fuel = 85*1000*1000

				local inventory = cargo_inventory.get_item_count(item)
				rendering.set_text(text, is_full and {"inventory-full-message.main"} or inventory)

				stack_transfer_timer = stack_transfer_timer + 1
				if stack_transfer_timer % 15 == 0 and train.state == defines.train_state.wait_station then
					local inserted = cargo_inventory.insert{
						name = item,
						count = 100
					}
					if inserted > 0 then
						wagon_inventory.remove{
							name = item,
							count = inserted
						}
					else
						is_full = true
					end
				end
			]]
		}
	}
}
