-- uses global['train-stations'] to list all train stations {station, stop}
-- uses global['player-build-error-debounce'] to track force -> last error tick to de-duplicate placement errors
-- uses global['trains-accounted-for'] to track train IDs that have already been counted by a station in the last cycle
local io = require("scripts.lualib.input-output")
local getitems = require("scripts.lualib.get-items-from")
local math2d = require("math2d")

local station = "train-station"
local freight = "freight-platform"
local fluid = "fluid-freight-platform"
local empty = "empty-platform"
local trainstop = "train-stop"
local stop_pos = {2,-2.5}
local storage_pos = {3.5,0}

local function refundEntity(entity, reason, event)
	-- refund the entity and trigger an error message flying text (but only if event.tick is not too recent from the last one)
	local player = entity.last_user
	if player then
		if not player.cursor_stack.valid_for_read then
			player.cursor_stack.set_stack{name=entity.name,count=1}
		else
			player.insert{name=entity.name,count=1}
		end
		if not global['player-build-error-debounce'] then global['player-build-error-debounce'] = {} end
		if not global['player-build-error-debounce'][player.force.index] or global['player-build-error-debounce'][player.force.index] < event.tick then
			player.surface.create_entity{
				name = "flying-text",
				position = entity.position,
				text = reason,
				render_player_index = player.index
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
			global['player-build-error-debounce'][player.force.index] = event.tick + 60
		end
	else
		entity.surface.spill_item_stack(entity.position, {name=entity.name,count=1}, false, nil, false)
	end
	entity.destroy()
end

local function assertPosition(entity, position)
	-- ensures that the entity is at the *exact* expected position
	if not (entity and entity.valid) then return false end
	if math.abs((entity.position.x or entity.position[1]) - (position.x or position[1])) > 0.01 then return false end
	if math.abs((entity.position.y or entity.position[2]) - (position.y or position[2])) > 0.01 then return false end
	return true
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == station or entity.name == freight or entity.name == fluid or entity.name == empty then
		-- check if it collides with something
		local colliders = entity.surface.find_entities_filtered{
			area = entity.bounding_box,
			collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"}
		}
		for _,collider in pairs(colliders) do
			if collider ~= entity and collider.name ~= "straight-rail" then
				return refundEntity(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
			end
			if collider.name == "straight-rail" then
				-- only allowed on the central line, and even then only in the same direction
				if collider.direction%4 ~= entity.direction%4 then -- rails are limited to north/east
					return refundEntity(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
				end
				if entity.direction == defines.direction.north or entity.direction == defines.direction.south then
					if collider.position.x ~= entity.position.x then
						return refundEntity(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
					end
				else
					if collider.position.y ~= entity.position.y then
						return refundEntity(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
					end
				end
			end
		end
		if entity.name == station then
			-- station must be on rail grid
			-- entity is 7x14 and station is placed at {2,-2.5} relative to the entity
			local stationpos = math2d.position.add(entity.position, math2d.position.rotate_vector(stop_pos, entity.direction*45))
			stationpos.x = math.floor(stationpos.x+0.001) -- epsilon for checking if entity is on the grid
			stationpos.y = math.floor(stationpos.y+0.001)
			-- stationpos should now be on the 2x2 grid, that is the grid where centre points are ODD
			if stationpos.x%2 ~= 1 or stationpos.y%2 ~= 1 then
				return refundEntity(entity, {"message.entity-must-be-placed-on-rail-grid",{"entity-name."..entity.name}}, event)
			end

			local stop = entity.surface.create_entity{
				name = "train-stop",
				position = stationpos,
				direction = entity.direction,
				force = entity.force,
				raise_built = true
			}
			stop.rotatable = false

			if not global['train-stations'] then global['train-stations'] = {} end
			global['train-stations'][entity.unit_number] = {station=entity, stop=stop}
		else
			-- platforms must be adjacent to another platform or a station
			local before = math2d.position.add(entity.position, math2d.position.rotate_vector({0,-7}, entity.direction*45))
			local behind = math2d.position.add(entity.position, math2d.position.rotate_vector({0,7}, entity.direction*45))
			if not (
				assertPosition(entity.surface.find_entity(station, before), before) or assertPosition(entity.surface.find_entity(station, behind), behind)
				or assertPosition(entity.surface.find_entity(freight, before), before) or assertPosition(entity.surface.find_entity(freight, behind), behind)
				or assertPosition(entity.surface.find_entity(fluid, before), before) or assertPosition(entity.surface.find_entity(fluid, behind), behind)
				or assertPosition(entity.surface.find_entity(empty, before), before) or assertPosition(entity.surface.find_entity(empty, behind), behind)
			) then
				return refundEntity(entity, {"message.entity-must-be-placed-next-to-platform",{"entity-name."..entity.name}}, event)
			end

			if entity.name == freight then
				local store = entity.surface.create_entity{
					name = entity.name.."-box",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector(storage_pos, entity.direction*45)),
					force = entity.force,
					raise_built = true
				}
				io.addOutput(entity, {6.5,-2}, store, defines.direction.east)
				io.addInput(entity, {6.5,-1}, store, defines.direction.west)
				io.addInput(entity, {6.5,1}, store, defines.direction.west)
				io.addOutput(entity, {6.5,2}, store, defines.direction.east)
				-- default to Input mode
				io.toggle(entity, {6.5,-2}, false)
				io.toggle(entity, {6.5,2}, false)
			end
			if entity.name == fluid then
				entity.surface.create_entity{
					name = entity.name.."-tank",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector(storage_pos, entity.direction*45)),
					direction = entity.direction,
					force = entity.force,
					raise_built = true
				}.rotatable = false
				local pump = entity.surface.create_entity{
					name = entity.name.."-pump",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector({6.5,-2}, entity.direction*45)),
					direction = (entity.direction + 2) % 8,
					force = entity.force,
					raise_built = true
				}
				pump.rotatable = false
				pump.active = false
				entity.surface.create_entity{
					name = entity.name.."-pump",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector({6.5,-1}, entity.direction*45)),
					direction = (entity.direction + 6) % 8,
					force = entity.force,
					raise_built = true
				}.rotatable = false
				entity.surface.create_entity{
					name = entity.name.."-pump",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector({6.5,1}, entity.direction*45)),
					direction = (entity.direction + 6) % 8,
					force = entity.force,
					raise_built = true
				}.rotatable = false
				pump = entity.surface.create_entity{
					name = entity.name.."-pump",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector({6.5,2}, entity.direction*45)),
					direction = (entity.direction + 2) % 8,
					force = entity.force,
					raise_built = true
				}
				pump.rotatable = false
				pump.active = false
			end
		end
		entity.rotatable = false

		entity.surface.create_entity{
			name = entity.name.."-walkable", -- left side in direction of travel is walkable
			position = math2d.position.add(entity.position, math2d.position.rotate_vector({-4,0}, entity.direction*45)),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		entity.surface.create_entity{
			name = (entity.name == station or entity.name == empty) and entity.name.."-walkable" or entity.name.."-collision", -- right side is blocked by freight
			position = math2d.position.add(entity.position, math2d.position.rotate_vector({4,0}, entity.direction*45)),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == trainstop or entity.name == freight.."-box" or entity.name == fluid.."-tank" or entity.name == fluid.."-pump" then
		local floor = entity.surface.find_entities_filtered{
			name = {station, freight, fluid, empty},
			position = entity.position
		}[1]
		floor.destroy({raise_destroy=true})
		return
	end
	if entity.name == station or entity.name == freight or entity.name == fluid or entity.name == empty then
		local names
		if entity.name == station then
			names = {entity.name.."-walkable", trainstop}
			-- remove from global table
			global['train-stations'][entity.unit_number] = nil
		elseif entity.name == freight then
			names = {entity.name.."-walkable", entity.name.."-collision", entity.name.."-box"}
			io.remove(entity, event)
		elseif entity.name == fluid then
			names = {entity.name.."-walkable", entity.name.."-collision", entity.name.."-tank", entity.name.."-pump"}
		else
			names = {entity.name.."-walkable"}
		end

		local blocks = entity.surface.find_entities_filtered{
			name = names,
			area = entity.bounding_box
		}
		for _,block in pairs(blocks) do
			if block.type == "container" then
				getitems.storage(block, event and event.buffer or nil)
			end
			block.destroy()
		end
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.name == station or event.entity.name == freight or event.entity.name == fluid then
		-- opening the combinator instead opens the storage
		player.opened = event.entity.surface.find_entities_filtered{
			name = {trainstop, freight.."-box", fluid.."-tank"},
			area = event.entity.bounding_box
		}[1]
	end
	if event.entity.name == freight.."-box" or event.entity.name == fluid.."-tank" then
		local floor = event.entity.surface.find_entity(event.entity.name == freight.."-box" and freight or fluid, event.entity.position)
		local unloading
		if event.entity.name == freight.."-box" then
			unloading = io.isEnabled(floor,{6.5,-2})
		else
			unloading = floor.surface.find_entity(
				fluid.."-pump",
				math2d.position.add(floor.position, math2d.position.rotate_vector({6.5,-2}, floor.direction*45))
			).active
		end
		-- create additional GUI for switching input/output mode (re-use truck station GUI)
		local gui = player.gui.left
		if not gui['truck-station-gui'] then
			local frame = gui.add{
				type = "frame",
				name = "truck-station-gui",
				direction = "vertical",
				caption = {"gui.truck-station-gui-title"},
				style = mod_gui.frame_style
			}
			frame.style.horizontally_stretchable = false
			frame.style.use_header_filler = false
			frame.add{
				type = "switch",
				name = "truck-station-mode-toggle",
				switch_state = unloading and "right" or "left",
				left_label_caption = {"gui.truck-station-mode-load"},
				right_label_caption = {"gui.truck-station-mode-unload"}
			}
		else
			gui['truck-station-gui'].visible = true
		end
		gui['truck-station-gui'].caption = {"entity-name."..event.entity.name}
		gui['truck-station-gui']['truck-station-mode-toggle'].switch_state = unloading and "right" or "left"
	end
end
local function onGuiSwitch(event)
	if event.element.valid and event.element.name == "truck-station-mode-toggle" then
		local player = game.players[event.player_index]
		if player.opened.name == freight.."-box" then
			local floor = player.opened.surface.find_entity(freight, player.opened.position)
			local unload = event.element.switch_state == "right"
			io.toggle(floor,{6.5,-2},unload)
			io.toggle(floor,{6.5,-1},not unload)
			io.toggle(floor,{6.5,1},not unload)
			io.toggle(floor,{6.5,2},unload)
		end
		if player.opened.name == fluid.."-tank" then
			local floor = player.opened.surface.find_entity(fluid, player.opened.position)
			local unload = event.element.switch_state == "right"
			floor.surface.find_entity(
				fluid.."-pump",
				math2d.position.add(floor.position, math2d.position.rotate_vector({6.5,-2}, floor.direction*45))
			).active = unload
			floor.surface.find_entity(
				fluid.."-pump",
				math2d.position.add(floor.position, math2d.position.rotate_vector({6.5,-1}, floor.direction*45))
			).active = not unload
			floor.surface.find_entity(
				fluid.."-pump",
				math2d.position.add(floor.position, math2d.position.rotate_vector({6.5,1}, floor.direction*45))
			).active = not unload
			floor.surface.find_entity(
				fluid.."-pump",
				math2d.position.add(floor.position, math2d.position.rotate_vector({6.5,2}, floor.direction*45))
			).active = unload
		end
	end
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and (event.entity.name == freight.."-box" or event.entity.name == fluid.."-tank") then
		local player = game.players[event.player_index]
		local gui = player.gui.left['truck-station-gui']
		if gui then gui.visible = false end
	end
end

local function onTick(event)
	if not global['train-stations'] then return end
	
	if not global['trains-accounted-for'] or event.tick%60 == 0 then global['trains-accounted-for'] = {} end
	-- poll every station once per second
	for i,struct in pairs(global['train-stations']) do
		local station = struct.station
		local stop = struct.stop
		if event.tick%60 == i%60 and station.energy >= 1000 then
			-- each station will "tick" once every second
			local trains = stop.get_train_stop_trains()
			local power = 50 -- MJ consumed this second
			for i,train in pairs(trains) do
				-- ensure trains are only accounted for by one station
				-- this is reset every half-second, ie. every modulo
				if not global['trains-accounted-for'][train.id] then
					global['trains-accounted-for'][train.id] = true
					-- each train consumes 25MW normally, plus up to 85MW more to recharge its power
					for _,dir in pairs({"front_movers","back_movers"}) do
						for _,loco in pairs(train.locomotives[dir]) do
							local burner = loco.burner
							if not burner.currently_burning then burner.currently_burning = "train-power" end
							local missing = 85*1000*1000 - burner.remaining_burning_fuel
							power = power + 25 + missing/1000/1000
							burner.remaining_burning_fuel = 85*1000*1000
						end
					end
					-- it's okay to just set max power here, as the following second will rapidly drain the station's energy and cause a blackout if power usage is too high
					-- if there are two power grids trying to account for this train, then this block won't be reached if the first is blacked out, so it's all good!
				end
			end
			station.power_usage = power*1000*1000/60 -- set power usage for the next second based on power consumed in the last second
			station.electric_buffer_size = math.max(station.electric_buffer_size, station.power_usage)
		end
	end

	-- one transfer every 45 ticks = 24 seconds for a 32-stack freight car
	local energy_used = (50/60*45)*1000*1000
	for i,struct in pairs(global['train-stations']) do
		local station = struct.station
		local stop = struct.stop
		if event.tick%45 == i%45 and station.energy >= 1000 then
			local train = stop.get_stopped_train()
			-- scan attached platforms and, if a matching wagon is present, handle loading/unloading
			local delta = math2d.position.rotate_vector({0,7},station.direction*45)
			local position = station.position
			while true do
				position = math2d.position.add(position, delta)
				local platform = station.surface.find_entities_filtered{
					name = {freight, fluid, empty},
					position = position,
					force = station.force
				}[1]
				if not assertPosition(platform, position) then break end
				
				if platform.name == freight and platform.energy >= energy_used then
					local wagon = station.surface.find_entity("cargo-wagon", position)
					if train and wagon then
						local is_output = io.isEnabled(platform,{6.5,-2})
						local wagoninventory = wagon.get_inventory(defines.inventory.cargo_wagon)
						local store = station.surface.find_entity(freight.."-box", math2d.position.add(platform.position, math2d.position.rotate_vector(storage_pos, platform.direction*45)))
						local storeinventory = store.get_inventory(defines.inventory.chest)
						-- transfer one item stack
						local from = is_output and wagoninventory or storeinventory
						local to = is_output and storeinventory or wagoninventory
						local target = to.find_empty_stack()
						if target and not from.is_empty() then
							for name,_ in pairs(from.get_contents()) do
								local source = from.find_item_stack(name)
								-- since there is an empty stack, an insert will always succeed
								from.remove({name=name,count=to.insert(source)})
								platform.energy = platform.energy - energy_used
								break
							end
						end
					end
					io.toggle(platform,{6.5,-1},not (train and wagon))
					io.toggle(platform,{6.5,1},not (train and wagon))
				elseif platform.name == fluid and platform.energy >= energy_used then
					local wagon = station.surface.find_entity("fluid-wagon", position)
					if train and wagon then
						local is_output = station.surface.find_entity(
							fluid.."-pump",
							math2d.position.add(platform.position, math2d.position.rotate_vector({6.5,-2}, platform.direction*45))
						).active
						local store = station.surface.find_entity(fluid.."-tank", math2d.position.add(platform.position, math2d.position.rotate_vector(storage_pos, platform.direction*45)))
						-- transfer 50 units
						local from = is_output and wagon or store
						local to = is_output and store or wagon
						local amount = math.min(50, from.get_fluid_count())
						if amount > 0 then
							for name,_ in pairs(from.get_fluid_contents()) do
								amount = to.insert_fluid{name=name,amount=amount}
								if amount > 0 then
									from.remove_fluid{name=name,amount=amount}
									platform.energy = platform.energy - energy_used*amount/50 -- uses less power if not all fluid is transferred
								end
								break
							end
						end
					end
					station.surface.find_entity(
						fluid.."-pump",
						math2d.position.add(platform.position, math2d.position.rotate_vector({6.5,-1}, platform.direction*45))
					).active = not (train and wagon)
					station.surface.find_entity(
						fluid.."-pump",
						math2d.position.add(platform.position, math2d.position.rotate_vector({6.5,1}, platform.direction*45))
					).active = not (train and wagon)
				end
			end
		end
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_switch_state_changed] = onGuiSwitch,

		[defines.events.on_tick] = onTick
	}
}