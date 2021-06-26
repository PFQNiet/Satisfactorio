-- uses global.trucks.stations to list all truck stations
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local fastTransfer = require(modpath.."scripts.organisation.containers").fastTransfer
local link = require(modpath.."scripts.lualib.linked-entity")
local math2d = require("math2d")

local base = "truck-station"
local storage = base.."-box"
local storage_pos = {1,-0.5}
local fuelbox = base.."-fuelbox"
local fuelbox_pos = {-4,2.5}

local script_data = {
	stations = {}
}
for i=0,30-1 do script_data.stations[i] = {} end
local function getStruct(floor)
	return script_data.stations[floor.unit_number%30][floor.unit_number]
end
local function clearStruct(floor)
	script_data.stations[floor.unit_number%30][floor.unit_number] = nil
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		-- add storage boxes
		local store = entity.surface.create_entity{
			name = storage,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(storage_pos, entity.direction*45)),
			force = entity.force,
			raise_built = true
		}
		local fuel = entity.surface.create_entity{
			name = fuelbox,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(fuelbox_pos, entity.direction*45)),
			force = entity.force,
			raise_built = true
		}
		link.register(entity, fuel)
		link.register(entity, store)
		io.addConnection(entity, {-4,3.5}, "input", fuel)
		io.addConnection(entity, {0,3.5}, "input", store)
		io.addConnection(entity, {2,3.5}, "output", store, defines.direction.south)
		entity.rotatable = false
		script_data.stations[entity.unit_number%30][entity.unit_number] = {
			base = entity,
			fuel = fuel,
			cargo = store,
			mode = "input"
		}
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		script_data.stations[entity.unit_number%30][entity.unit_number] = nil
	end
end

local function checkRangeForTabs(player, gui, fuel, cargo)
	if not (gui and gui.valid) then return end
	for i,obj in pairs({fuel,cargo}) do
		local reach = player.can_reach_entity(obj)
		local tab = gui.tabs[i].tab
		tab.enabled = reach
		if reach then tab.tooltip = "" else tab.tooltip = {"cant-reach"} end
	end
end
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	if not (event.entity and event.entity.valid) then return end
	if event.entity.name == base then
		-- opening the base instead opens the storage
		local data = getStruct(event.entity)
		if player.can_reach_entity(data.cargo) then
			player.opened = data.cargo
		else
			player.opened = nil
			player.create_local_flying_text{
				text = {"cant-reach"},
				create_at_cursor = true
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
		end
	end
	if event.entity.name ~= storage and event.entity.name ~= fuelbox then return end
	local floor = event.entity.surface.find_entity(base, event.entity.position)
	local data = getStruct(floor)
	if event.entity.name == storage then
		local unloading = data.mode == "output"
		-- create additional GUI for switching input/output mode
		local gui = player.gui.relative
		if not gui['truck-station-gui'] then
			local frame = gui.add{
				type = "frame",
				name = "truck-station-gui",
				anchor = {
					gui = defines.relative_gui_type.container_gui,
					position = defines.relative_gui_position.right
				},
				direction = "vertical",
				caption = {"gui.truck-station-gui-title"},
				style = "inset_frame_container_frame"
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
		gui['truck-station-gui']['truck-station-mode-toggle'].switch_state = unloading and "right" or "left"
	end
	local gui = player.gui.relative
	-- create fake tabs for switching to the fuel crate
	if not gui['truck-station-tabs'] then
		local tabs = gui.add{
			type = "tabbed-pane",
			name = "truck-station-tabs",
			anchor = {
				gui = defines.relative_gui_type.container_gui,
				position = defines.relative_gui_position.top
			},
			style = "tabbed_pane_with_no_side_padding_and_tabs_hidden"
		}
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
				caption = {"gui.station-cargo"}
			},
			tabs.add{type="empty-widget"}
		)
	end
	gui['truck-station-tabs'].selected_tab_index = event.entity.name == fuelbox and 1 or 2
	checkRangeForTabs(player, gui['truck-station-tabs'], data.fuel, data.cargo)
end
local function onMove(event)
	-- update tab enabled state based on reach
	local player = game.players[event.player_index]
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local entity = player.opened
	if entity.name ~= storage and entity.name ~= fuelbox then return end
	local floor = entity.surface.find_entity(base, entity.position)
	local data = getStruct(floor)
	local gui = player.gui.relative
	checkRangeForTabs(player, gui['truck-station-tabs'], data.fuel, data.cargo)
end
local function onGuiSwitch(event)
	if event.element.valid and event.element.name == "truck-station-mode-toggle" then
		local player = game.players[event.player_index]
		if player.opened.name == storage then
			local floor = player.opened.surface.find_entity(base, player.opened.position)
			local data = getStruct(floor)
			local unload = event.element.switch_state == "right"
			data.mode = unload and "output" or "input"
		end
	end
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and event.entity.valid then
		local player = game.players[event.player_index]
		if event.entity.name == storage then
			local gui = player.gui.relative['truck-station-gui']
			if gui then gui.destroy() end
		end
		if event.entity.name == storage or event.entity.name == fuelbox then
			local gui = player.gui.relative['truck-station-tabs']
			if gui then gui.destroy() end
		end
	end
end
local function onGuiTabChange(event)
	if event.element.valid and event.element.name == "truck-station-tabs" then
		local player = game.players[event.player_index]
		local opened = player.opened -- either the storage or the fuelbox
		local floor = opened.surface.find_entity(base, opened.position)
		local data = getStruct(floor)
		if event.element.selected_tab_index == 1 then
			player.opened = data.fuel
		else
			player.opened = data.cargo
		end
	end
end

local function onTick(event)
	for i,struct in pairs(script_data.stations[event.tick%30]) do
		local station = struct.base
		local fuel = struct.fuel
		local store = struct.cargo
		local mode = struct.mode
		if station.energy > 0 then
			-- each station will "tick" once every 30 in-game ticks, ie. every half-second
			local centre = math2d.position.add(station.position, math2d.position.rotate_vector({-0.5,-8}, station.direction*45))
			local vehicles = station.surface.find_entities_filtered{
				name = {"tractor","truck","explorer"},
				area = {{centre.x-4,centre.y-4}, {centre.x+4,centre.y+4}}
			}
			local done = false
			for _,vehicle in pairs(vehicles) do
				if vehicle.speed == 0 then
					-- always load fuel if possible
					local fuelinventory = vehicle.get_inventory(defines.inventory.fuel)
					local fuelstore = fuel.get_inventory(defines.inventory.chest)
					if not fuelstore.is_empty() then
						if fuelinventory.can_insert(fuelstore[1]) then
							fuelstore.remove({name=fuelstore[1].name, count=fuelinventory.insert(fuelstore[1])})
						end
					end

					local is_output = mode == "output"
					local vehicleinventory = vehicle.get_inventory(defines.inventory.car_trunk)
					local storeinventory = store.get_inventory(defines.inventory.chest)
					-- transfer one item stack
					local from = is_output and vehicleinventory or storeinventory
					local to = is_output and storeinventory or vehicleinventory
					local target = to.find_empty_stack()
					if target and not from.is_empty() then
						for name,_ in pairs(from.get_contents()) do
							local source = from.find_item_stack(name)
							-- since there is an empty stack, an insert will always succeed
							from.remove({name=name,count=to.insert(source)})
							break
						end
					end
					done = true
					break
				end
			end
			station.active = done
			-- disable IO if a vehicle is present, enable it if not
			io.toggle(station,not done)
		end
	end
end

local function onFastTransfer(event, half)
	local player = game.players[event.player_index]
	local target = player.selected
	if not (target and target.valid and target.name == base) then return end
	local data = getStruct(target)
	if not data then return end
	if player.cursor_stack.valid_for_read then
		-- vehicles accept all fuel so just check if a fuel value exists on the item
		if player.cursor_stack.prototype.fuel_value then
			-- attempt to place in fuel box
			if fastTransfer(player, data.fuel, half) then return end
		end
		-- otherwise, or if it can't go in the fuel box, put it in cargo
		fastTransfer(player, data.cargo, half)
	else
		-- retrieve items from cargo, or from fuel box if cargo is empty
		if not fastTransfer(player, data.cargo, half) then
			fastTransfer(player, data.fuel, half)
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.trucks = global.trucks or script_data
	end,
	on_load = function()
		script_data = global.trucks or script_data
	end,
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_switch_state_changed] = onGuiSwitch,
		[defines.events.on_gui_selected_tab_changed] = onGuiTabChange,
		[defines.events.on_player_changed_position] = onMove,

		[defines.events.on_tick] = onTick,

		["fast-entity-transfer-hook"] = function(event) onFastTransfer(event, false) end,
		["fast-entity-split-hook"] = function(event) onFastTransfer(event, true) end
	}
}
