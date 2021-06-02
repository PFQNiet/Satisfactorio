-- uses global.drones.ports to list all ports
-- uses global.drones.drones to map drones back to their port
-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors
local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local refundEntity = require(modpath.."scripts.build-gun").refundEntity
local math2d = require("math2d")

local base = "drone-port"
local storage = base.."-box"
local storage_pos_out = {-2.5,-1.5}
local storage_pos_in = {2.5,-1.5}
local fuelbox = base.."-fuelbox"
local fuelbox_pos = {-3.5,3.5}
local drone = "drone"

local debounce_error = {}
local script_data = {
	ports = {},
	drones = {}
}
for i=0,30-1 do script_data.ports[i] = {} end
local function getStruct(floor)
	return script_data.ports[floor.unit_number%30][floor.unit_number]
end
local function getStructFromDrone(drone)
	local port = script_data.drones[drone.unit_number]
	return port and script_data.ports[port.unit_number%30][port.unit_number]
end
local function clearStruct(floor)
	script_data.ports[floor.unit_number%30][floor.unit_number] = nil
end

local function rejectBuild(event, entity, reason)
	local player = entity.last_user
	refundEntity(player, entity)
	if player then
		if not debounce_error[player.force.index] or debounce_error[player.force.index] < event.tick then
			player.create_local_flying_text{
				text = reason,
				create_at_cursor = true
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
			debounce_error[player.force.index] = event.tick + 60
		end
	end
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		-- add storage boxes
		local store1 = entity.surface.create_entity{
			name = storage,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(storage_pos_out, entity.direction*45)),
			force = entity.force,
			raise_built = true
		}
		local store2 = entity.surface.create_entity{
			name = storage,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(storage_pos_in, entity.direction*45)),
			force = entity.force,
			raise_built = true
		}
		local fuel = entity.surface.create_entity{
			name = fuelbox,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(fuelbox_pos, entity.direction*45)),
			force = entity.force,
			raise_built = true
		}
		io.addInput(entity, {-3.5,5.5}, fuel)
		io.addInput(entity, {1.5,5.5}, store1)
		io.addOutput(entity, {3.5,5.5}, store2, defines.direction.south)
		entity.rotatable = false
		script_data.ports[entity.unit_number%30][entity.unit_number] = {
			base = entity,
			fuel = fuel,
			export = store1,
			import = store2,
			target = nil,
			state = {
				status = "no-drone"
			},
			drone = nil,
			guests = {}
		}
	end
	if entity.name == drone then
		-- ensure there is a drone port here
		local port = entity.surface.find_entity(base, entity.position)
		if not port then
			return rejectBuild(event, entity, {"message.drone-must-be-built-on-port"})
		end
		local data = getStruct(port)
		if data.drone then
			return rejectBuild(event, entity, {"message.drone-port-has-another-drone"})
		end
		if #data.guests > 0 then
			return rejectBuild(event, entity, {"message.drone-port-is-busy"})
		end
		data.drone = entity
		table.insert(data.guests, entity)
		data.state.status = "loading"
		script_data.drones[entity.unit_number] = port.unit_number
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == base or entity.name == storage or entity.name == fuelbox then
		local floor = entity.name == base and entity or entity.surface.find_entity(base, entity.position)
		local data = getStruct(floor)

		local import = data.import
		local export = data.export
		local fuel = data.fuel
		local drone = data.drone
		if entity.unit_number ~= import.unit_number then
			getitems.storage(import, event and event.buffer or nil)
			import.destroy()
		end
		if entity.unit_number ~= export.unit_number then
			getitems.storage(export, event and event.buffer or nil)
			export.destroy()
		end
		if entity.name ~= fuelbox then
			getitems.storage(fuel, event and event.buffer or nil)
			fuel.destroy()
		end
		if drone then
			getitems.burner(drone, event and event.buffer or nil)
			getitems.spider(drone, event and event.buffer or nil)
			drone.destroy()
		end
		io.remove(floor, event)

		script_data.ports[floor.unit_number%30][floor.unit_number] = nil
		if entity.name ~= base then
			floor.destroy()
		end
	end
	if entity.name == drone then
		local data = getStructFromDrone(entity)
		if data then
			data.state.status = "no-drone"
			data.drone = nil
		end
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.valid then
		if event.entity.name == base or event.entity.name == storage or event.entity.name == fuelbox then
			local floor = event.entity.name == base and event.entity or event.entity.surface.find_entity(base, event.entity.position)
			local data = getStruct(floor)
			local gui = player.gui.relative
			-- create fake tabs for switching to the fuel crate
			if not gui['drone-port-tabs'] then
				local tabs = gui.add{
					type = "tabbed-pane",
					name = "drone-port-tabs",
					anchor = {
						gui = defines.relative_gui_type.container_gui,
						position = defines.relative_gui_position.top
					},
					style = "tabbed_pane_with_no_side_padding_and_tabs_hidden"
				}
				tabs.add_tab(
					tabs.add{
						type = "tab",
						caption = {"gui.station-drone"}
					},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{
						type = "tab",
						caption = {"gui.station-fuel-box"}
					},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{
						type = "tab",
						caption = {"gui.station-export"}
					},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{
						type = "tab",
						caption = {"gui.station-import"}
					},
					tabs.add{type="empty-widget"}
				)
			end
			local tab = 1
			if event.entity.name == storage then
				tab = event.entity == data.import and 4 or 3
			else
				tab = 2
			end
			gui['drone-port-tabs'].selected_tab_index = tab
		end
	end
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and event.entity.valid then
		local player = game.players[event.player_index]
		if event.entity.name == storage or event.entity.name == fuelbox then
			local gui = player.gui.relative['drone-port-tabs']
			if gui then gui.destroy() end
		end
	end
end
local function onGuiTabChange(event)
	if event.element.valid and event.element.name == "drone-port-tabs" then
		local player = game.players[event.player_index]
		local opened = player.opened -- either the storage or the fuelbox
		local floor = opened.surface.find_entity(base, opened.position)
		local data = getStruct(floor)
		local indexed_parts = {data.base, data.fuel, data.export, data.import}
		player.opened = indexed_parts[event.element.selected_tab_index]
	end
end

local function transferInventory(source, target)
	for i=1,#source do
		local stack = source[i]
		if stack.valid and stack.valid_for_read then
			if target.can_insert(stack) then
				source.remove{name=stack.name, count=target.insert(stack)}
			end
		end
	end
end
local function onTick(event)
	for i,struct in pairs(script_data.ports[event.tick%30]) do
		local station = struct.base
		local destination = struct.target
		local fuel = struct.fuel
		local import = struct.import
		local export = struct.export
		local drone = struct.drone
		local status = struct.state
		local guests = struct.guests
		if station.energy > 0 then
			-- each station will "tick" once every 30 in-game ticks, ie. every half-second
			if state.status == "no-drone" or state.status == "emergency-recall" then
				-- do nothing
			elseif state.status == "loading" then
				local source = drone.get_inventory(defines.inventory.spider_trunk)
				local target = import.get_inventory(defines.inventory.chest)
				transferInventory(source, target)
				if source.is_empty() then
					state.status = "waiting-for-destination"
				end
			elseif state.status == "waiting-for-destination" then
				if destination and destination.valid then
					local source = export.get_inventory(defines.inventory.chest)
					local target = drone.get_inventory(defines.inventory.spider_trunk)
					transferInventory(source, target)

					-- take batteries and initiate takeoff
					local fuelstore = fuel.get_inventory(defines.inventory.chest)
					local fueltarget = drone.get_inventory(defines.inventory.fuel)
					if not fuelstore.is_empty() then
						if fueltarget.can_insert(fuelstore[1]) then
							fuelstore.remove({name=fuelstore[1].name, count=fueltarget.insert(fuelstore[1])})
						end
					end
					if not fueltarget.is_empty() and fueltarget[1].count >= 10 then
						state.status = "takeoff"
						state.delay = event.tick + 25*60
					end
				end
			elseif state.status == "takeoff" then
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				elseif event.tick > state.delay then
					-- remove self from queue - self will always be front of the queue at this point
					table.remove(guests, 1)
					state.status = "outbound"
					drone.autopilot_destination = destination.position
				end
			elseif state.status == "outbound" then
				-- do nothing; wait for on_spider_command_completed event
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				end
			elseif state.status == "reached-destination" then
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				else
					-- register arrival into the destination queue
					local ddata = getStruct(destination)
					table.insert(ddata.guests, drone)
					state.status = "waiting-to-arrive"
				end
			elseif state.status == "waiting-to-arrive" then
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				else
					local ddata = getStruct(destination)
					local qpos
					for i=1,#ddata.guests do
						if ddata.guests[i] == drone then
							qpos = i
							break
						end
					end
					if qpos == 1 and not (ddata.state.status == "loading" or ddata.state.status == "takeoff" or ddata.state.status == "landing") then
						-- it's my turn!
						state.status = "arriving"
						state.delay = event.tick + 25*60
					else
						drone.autopilot_destination = math2d.position.add(
							destination.position,
							math2d.position.rotate_vector({0,-3}, (qpos-1)/#ddata.guests*360)
						)
					end
				end
			elseif state.status == "arriving" then
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				elseif event.tick > state.delay then
					state.status = "unloading"
				end
			elseif state.status == "unloading" then
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				else
					local ddata = getStruct(destination)
					-- deliver items, pick up stuff, grab some batteries and come home
					local source = drone.get_inventory(defines.inventory.spider_trunk)
					local target = ddata.import.get_inventory(defines.inventory.chest)
					transferInventory(source, target)
					if source.is_empty() then
						local chest = ddata.export.get_inventory(defines.inventory.chest)
						transferInventory(chest, source)
	
						-- take batteries and initiate takeoff
						local fuelstore = ddata.fuel.get_inventory(defines.inventory.chest)
						local fueltarget = drone.get_inventory(defines.inventory.fuel)
						if not fuelstore.is_empty() then
							if fueltarget.can_insert(fuelstore[1]) then
								fuelstore.remove({name=fuelstore[1].name, count=fueltarget.insert(fuelstore[1])})
							end
						end
						if not fueltarget.is_empty() and fueltarget[1].count >= 10 then
							state.status = "leaving"
							state.delay = event.tick + 25*60
						end
					end
				end
			elseif state.status == "leaving" then
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				elseif event.tick > state.delay then
					local ddata = getStruct(destination)
					-- remove self from queue - self will always be front of the queue at this point
					table.remove(ddata.guests, 1)
					state.status = "inbound"
					drone.autopilot_destination = station.position
				end
			elseif state.status == "inbound" then
				-- do nothing; wait for on_spider_command_completed event
			elseif state.status == "reached-home" then
				-- register arrival into the queue
				table.insert(guests, drone)
				state.status = "waiting-to-return"
			elseif state.status == "waiting-to-return" then
				local qpos
				for i=1,#guests do
					if guests[i] == drone then
						qpos = i
						break
					end
				end
				if qpos == 1 then
					-- it's my turn!
					state.status = "landing"
					state.delay = event.tick + 25*60
				else
					drone.autopilot_destination = math2d.position.add(
						station.position,
						math2d.position.rotate_vector({0,-3}, (qpos-1)/#guests*360)
					)
				end
			elseif state.status == "landing" then
				if event.tick > state.delay then
					state.status = "loading"
				end
			elseif state.status == "emergency-arrival" then
				local qpos
				for i=1,#guests do
					if guests[i] == drone then
						qpos = i
						break
					end
				end
				if qpos == 1 then
					-- it's my turn!
					state.status = "emergency-landing"
					state.delay = event.tick + 25*60
				else
					drone.autopilot_destination = math2d.position.add(
						station.position,
						math2d.position.rotate_vector({0,-3}, (qpos-1)/#guests*360)
					)
				end
			elseif state.status == "emergency-landing" then
				if event.tick > state.delay then
					state.status = "waiting-for-destinaton" -- skip loading phase
				end
			else
				error("Unknown drone status "..state.status)
			end
		end
	end
end
local function onSpiderDone(event)
	local spider = event.vehicle
	if spider.name == drone then
		local data = getStructFromDrone(spider)
		if data.state.status == "outbound" then
			data.state.status = "reached-destination"
		elseif data.state.status == "inbound" then
			data.state.status = "reached-home"
		elseif data.state.status == "emergency-recall" then
			data.state.status = "emergency-arrival"
		end
	end
end

local function onSetupSpiderRemote(event)
	local player = game.players[event.player_index]
	local spider = event.vehicle
	if spider.name == drone then
		if player.cursor_stack.valid_for_read and player.cursor_stack.type == "spidertron-remote" then
			player.cursor_stack.connected_entity = nil
		end
		player.create_local_flying_text{
			text = {"message.drone-refuses-manual-control"},
			create_at_cursor = true
		}
		player.play_sound{
			path = "utility/cannot_build"
		}
	end
end

return {
	on_init = function()
		global.drones = global.drones or script_data
		global.debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		script_data = global.drones or script_data
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
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
		[defines.events.on_gui_selected_tab_changed] = onGuiTabChange,
		[defines.events.on_player_configured_spider_remote] = onSetupSpiderRemote,

		[defines.events.on_spider_command_completed] = onSpiderDone,
		[defines.events.on_tick] = onTick
	}
}
