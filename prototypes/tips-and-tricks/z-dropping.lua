local tip = data.raw['tips-and-tricks-item']['z-dropping']
tip.simulation = {
	init = tiptrickutils..[[
		player = game.create_test_player{name = "Niet"}
		player.teleport({0, 1.5})
		game.camera_player = player
		game.camera_player_cursor_position = player.position
		game.camera_alt_info = true
		
		drop = {-3.5,-2.5}
		box = game.surfaces[1].create_entity{name = "iron-chest", position = {-3.5,2.5}, force = "player"}
		game.surfaces[1].create_entity{name = "storage-container-placeholder", position = {-3.5,2.5}, force = "player"}
		belts = {}
		for i=1,6 do
			belts[i] = game.surfaces[1].create_entity{name = "transport-belt", position = {1.5+i,-1.5}, force = "player", direction = defines.direction.east}
		end
		smelter1 = game.surfaces[1].create_entity{name = "smelter", position = {2.5, 2.5}, force = "player", recipe = "iron-ingot"}
		smelter2 = game.surfaces[1].create_entity{name = "smelter", position = {5.5, 2.5}, force = "player", recipe = "iron-ingot"}
		
		game.surfaces[1].create_entity{name = "substation", position = {11, 0}, force = "player"}
		game.surfaces[1].create_entity{name = "electric-energy-interface", position = {11, 2}, force = "player"}
		io.generate(game.surfaces[1])
		
		fake_drop_to = function(entity)
			local stack = player.cursor_stack
			if not (stack.valid and stack.valid_for_read) then return end
			local name, count = stack.name, 1
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
		
		fake_drop_at_cursor = function()
			local stack = player.cursor_stack
			if not (stack and stack.valid_for_read) then return end
			
			local drop_stack = {name = stack.name, count = 1}
			game.surfaces[1].spill_item_stack(game.camera_player_cursor_position, drop_stack)
			player.remove_item(drop_stack)
			player.play_sound{path = "utility/drop_item"}
		end
		
		step_1 = function()
			player.cursor_stack.set_stack({name = "iron-ore", count = 50})
			script.on_nth_tick(1, function()
				if game.move_cursor({position = drop}) then
					step_2()
				end
			end)
		end
		
		step_2 = function()
			local repeat_time = 10
			local count = repeat_time
			local repeat_count = 15
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				count = repeat_time
				repeat_count = repeat_count - 1
				if repeat_count < 0 then
					step_3()
					return
				end
				fake_drop_at_cursor()
			end)
		end
		
		step_3 = function()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = box.position})
				if finished then
					step_4()
				end
			end)
		end
		
		step_4 = function()
			local repeat_time = 10
			local count = repeat_time
			local repeat_count = 10
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				count = repeat_time
				repeat_count = repeat_count - 1
				if repeat_count < 0 then
					step_6()
					return
				end
				fake_drop_to(player.selected)
			end)
		end
		
		step_6 = function()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = belts[1].position})
				if finished then
					step_7()
				end
			end)
		end
		
		step_7 = function()
			local repeat_time = 10
			local count = repeat_time
			local repeat_count = 10
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				count = repeat_time
				repeat_count = repeat_count - 1
				if repeat_count < 0 then
					step_8()
					return
				end
				fake_drop_at_cursor()
			end)
		end
		
		step_8 = function()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = smelter1.position})
				if finished then
					step_9()
				end
			end)
		end
		
		step_9 = function()
			local last_selected
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = smelter2.position})
				if player.selected and player.selected ~= last_selected then
					last_selected = player.selected
					fake_drop_to(player.selected)
				end
				if finished then
					step_10()
				end
			end)
		end
		
		step_10 = function()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = player.position})
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
				player.clear_cursor()
				for k, v in pairs (game.surfaces[1].find_entities()) do
					if v.type == "item-entity" then
						v.destroy()
					else
						v.clear_items_inside()
					end
				end
				start()
			end)
		end
		
		start = function()
			local count = 30
			script.on_nth_tick(1, function()
				count = count - 1
				if count > 0 then return end
				step_1()
			end)
		end
		
		start()
	]]
}
