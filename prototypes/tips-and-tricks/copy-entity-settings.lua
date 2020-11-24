local tip = data.raw['tips-and-tricks-item']['copy-entity-settings']
tip.simulation = {
	init = tiptrickutils..[[
		constructors = {}
		for i=1,4 do
			constructors[i] = game.surfaces[1].create_entity{name = "constructor", position = {-7.5+3*i,-1.5}, force = "player"}
		end
		constructors[1].set_recipe("iron-plate")
		io.generate(game.surfaces[1])
		
		player = game.create_test_player{name = "big k"}
		player.teleport({0, 3.5})
		game.camera_player = player
		game.camera_player_cursor_position = player.position
		game.camera_alt_info = true
		
		update_player_selected = function()
			player.update_selected_entity(game.camera_player_cursor_position)
			local selected = player.selected
			if not selected then
				if fake_source_box then
					fake_source_box.destroy()
					fake_source_box = nil
				end
				return
			end
			
			if copy_source and copy_source ~= selected then
				if fake_source_box then
					fake_source_box.destroy()
				end
				fake_source_box = game.surfaces[1].create_entity{name = "highlight-box", box_type = "copy", source = copy_source, position = copy_source.position}
			end
			
		end
		
		step_1 = function()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = {-4.5, -0.5}})
				update_player_selected()
				if finished then
					step_2()
				end
			end)
		end
		
		step_2 = function()
			local wait = 30
			copy_source = player.selected
			game.surfaces[1].play_sound{path = "utility/entity_settings_copied"}
			last_selected = player.selected
			script.on_nth_tick(1, function()
				wait = wait - 1
				if wait >= 0 then return end
				local finished = game.move_cursor{position = {4.5, -0.5}}
				update_player_selected()
				local selected = player.selected
				
				if selected ~= last_selected then
					last_selected = selected
					selected.copy_settings(copy_source, player)
				end
				
				if finished then
					step_3()
				end
			end)
		end
		
		step_3 = function()
			local wait = 30
			script.on_nth_tick(1, function()
				wait = wait - 1
				if wait > 0 then return end
				local finished = game.move_cursor({position = player.position})
				update_player_selected()
				if finished then
					reset()
				end
			end)
		end
		
		reset = function()
			local reset_tick = game.tick + 60
			script.on_nth_tick(1, function()
				if game.tick >= reset_tick then
					for k, v in pairs (game.surfaces[1].find_entities_filtered{name = "constructor"}) do
						if v ~= copy_source then
							v.set_recipe(nil)
						end
					end
					copy_source = nil
					start()
				end
			end)
		end
		
		start = function()
			local start_tick = game.tick + 60
			script.on_nth_tick(1, function()
				if game.tick >= start_tick then
					step_1()
				end
			end)
		end
		
		start()
	]]
}
