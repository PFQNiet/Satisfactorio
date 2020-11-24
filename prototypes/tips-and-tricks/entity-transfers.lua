local tip = data.raw['tips-and-tricks-item']['entity-transfers']
tip.tutorial = nil
tip.tag = "[item=portable-miner][item=smelter]"
tip.simulation = {
	init = tiptrickutils..[[
		player = game.create_test_player{name = "Niet"}
		player.teleport({0, 2.5})
		game.camera_player = player
		game.camera_player_cursor_position = player.position
		game.camera_alt_info = true
		
		game.surfaces[1].create_entity{name = "iron-ore", position = {-3.5, 1.5}, amount = 240}
		game.surfaces[1].create_entity{name = "portable-miner", position = {-3.5, 0.5}, force = "player"}
		miner1 = game.surfaces[1].create_entity{name = "portable-miner-box", position = {-3.5, 0.5}, force = "player"}
		game.surfaces[1].create_entity{name = "portable-miner", position = {-2.5, 0.5}, force = "player"}
		miner2 = game.surfaces[1].create_entity{name = "portable-miner-box", position = {-2.5, 0.5}, force = "player"}

		smelter1 = game.surfaces[1].create_entity{name = "smelter", position = {2.5, 0.5}, force = "player", recipe = "iron-ingot"}
		smelter2 = game.surfaces[1].create_entity{name = "smelter", position = {5.5, 0.5}, force = "player", recipe = "iron-ingot"}

		game.surfaces[1].create_entity{name = "substation", position = {11, 0}, force = "player"}
		game.surfaces[1].create_entity{name = "electric-energy-interface", position = {11, 2}, force = "player"}
		io.generate(game.surfaces[1])
		
		reset_items = function()
			miner1.clear_items_inside()
			miner1.insert({name = "iron-ore", count = 80})
			miner2.clear_items_inside()
			miner2.insert({name = "iron-ore", count = 80})
			
			smelter1.crafting_progress = 0
			smelter1.clear_items_inside()
			smelter1.get_output_inventory().insert{name="iron-ingot",count=40}
			smelter2.crafting_progress = 0
			smelter2.clear_items_inside()
			smelter2.get_output_inventory().insert{name="iron-ingot",count=40}
			
			player.clear_items_inside()
		end
		
		fake_transfer_to = function(entity)
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
			
			if not next(transferred) then return end
			
			local caption = {""}
			for name, count in pairs (transferred) do
				table.insert(caption, {"", "+",count," ",game.item_prototypes[name].localised_name," (",player.get_item_count(name),")\n"})
			end
			
			player.surface.create_entity{
				name = "flying-text",
				position = {entity.position.x, entity.position.y - 0.5},
				text = caption
			}
			player.play_sound{path = "utility/inventory_move"}
		end
		
		step_1 = function()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = miner1.position})
				if finished then
					step_2()
				end
			end)
		end
		
		step_2 = function()
			local count = 30
			local selected = nil
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				local finished = game.move_cursor({position = miner2.position})
				if player.selected and player.selected ~= selected then
					selected = player.selected
					fake_transfer_from(player.selected)
				end
				if finished then
					step_3()
				end
			end)
		end
		
		step_3 = function()
			local count = 30
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				
				local finished = game.move_cursor({position = {0, -1}})
				
				if finished then
					step_4()
				end
			end)
		end
		
		step_4 = function()
			local stack = player.get_main_inventory().find_item_stack("iron-ore")
			stack.swap_stack(player.cursor_stack)
			local count = 30
			local selected = nil
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				local finished = game.move_cursor({position = smelter2.position})
				if player.selected and player.selected ~= selected then
					selected = player.selected
					fake_transfer_to(player.selected)
				end
				if finished then
					step_5()
				end
			end)
		end
		
		step_5 = function()
			player.clear_cursor()
			local count = 30
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				local finished = game.move_cursor({position = {0, -1}})
				
				if finished then
					step_6()
				end
			end)
			
		end
		
		step_6 = function()
			local count = 30
			local selected = nil
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				local finished = game.move_cursor({position = smelter2.position})
				if player.selected and player.selected ~= selected then
					selected = player.selected
					fake_transfer_from(player.selected)
				end
				if finished then
					reset()
				end
			end)
		end
		
		reset = function()
			local count = 30
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				local finished = game.move_cursor({position = player.position})
				if finished then
					start()
				end
			end)
		end
		
		start = function()
			local count = 60
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				reset_items()
				step_1()
			end)
		end
		
		reset_items()
		start()
	]]
}
