-- uses global.drones.ports to list all ports
-- uses global.drones.drones to map drones back to their port
-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors
local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local fastTransfer = require(modpath.."scripts.organisation.containers").fastTransfer
local refundEntity = require(modpath.."scripts.build-gun").refundEntity
local math2d = require("math2d")

local base = "drone-port"
local storage = base.."-box"
local storage_pos_out = {-2.5,-1.5}
local storage_pos_in = {2.5,-1.5}
local fuelbox = base.."-fuelbox"
local fuelbox_pos = {-3.5,3.5}
local drone = "drone"
local sticker = drone.."-speed-sticker"

local debounce_error = {}
local script_data = {
	ports = {},
	drones = {}
}
for i=0,30-1 do script_data.ports[i] = {} end
local function getStructById(id)
	return script_data.ports[id%30][id]
end
local function getStruct(floor)
	return getStructById(floor.unit_number)
end
local function getStructFromDrone(drone)
	local port = script_data.drones[drone.unit_number]
	return port and getStructById(port)
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

local function findPortTag(floor)
	return floor.force.find_chart_tags(floor.surface, {{floor.position.x-0.1,floor.position.y-0.1},{floor.position.x+0.1,floor.position.y+0.1}})[1]
end
local function renamePortTag(floor, name)
	local tag = findPortTag(floor)
	if tag and tag.valid then
		tag.destroy()
		floor.force.add_chart_tag(floor.surface, {position=floor.position,icon={type="item",name=base},text=name})
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
		local name = game.backer_names[math.random(#game.backer_names)]
		script_data.ports[entity.unit_number%30][entity.unit_number] = {
			name = name,
			base = entity,
			fuel = fuel,
			export = store1,
			import = store2,
			target = nil,
			queued_target = nil, -- replaces current target on takeoff
			state = {
				status = "no-drone"
			},
			drone = nil,
			sticker = nil,
			guests = {},
			gui = {}
		}
		entity.force.add_chart_tag(entity.surface, {position=entity.position,icon={type="item",name=base},text=name})
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
		entity.teleport(port.position)
		data.drone = entity
		entity.entity_label = data.name
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
			-- check if drone is in destination queue
			local ddata = data.target and data.target.valid and getStruct(data.target)
			if ddata then
				for i,qd in pairs(ddata.guests) do
					if drone == qd then
						table.remove(ddata.guests,i)
						break
					end
				end
			end
		end
		io.remove(floor, event)
		local tag = findPortTag(floor)
		if tag and tag.valid then
			tag.destroy()
		end

		script_data.ports[floor.unit_number%30][floor.unit_number] = nil
		if entity.name ~= base then
			floor.destroy()
		end
	end
	if entity.name == drone then
		local data = getStructFromDrone(entity)
		if data then
			-- check if drone is in home or destination queues - it probably is if it stood still long enough to be mined!
			for i,drone in pairs(data.guests) do
				if drone == entity then
					table.remove(data.guests,i)
					break
				end
			end
			local ddata = data.target and data.target.valid and getStruct(data.target)
			if ddata then
				for i,drone in pairs(ddata.guests) do
					if drone == entity then
						table.remove(ddata.guests,i)
						break
					end
				end
			end
			data.state.status = "no-drone"
			data.drone = nil
		end
	end
end

local function updateStatusGui(data, pid)
	local status = data.state.status
	local delay = data.state.delay and math.ceil((data.state.delay - game.tick)/60) or 0
	if data.base.energy == 0 then
		status = "no-power"
	elseif data.drone and not data.drone.burner.currently_burning and data.drone.get_inventory(defines.inventory.fuel).is_empty() and data.state.status ~= "waiting-for-destination" then
		-- allowed to have no batteries when waiting for destination
		status = "out-of-batteries"
	end
	local statusmap = {
		["no-drone"] = "status_not_working",
		["no-power"] = "status_not_working",
		["out-of-batteries"] = "status_not_working",
		["waiting-for-destination"] = "status_not_working",
		["emergency-recall"] = "status_not_working",
		["emergency-arrival"] = "status_not_working",
		["emergency-landing"] = "status_not_working",
		["waiting-to-arrive"] = "status_yellow",
		["waiting-to-return"] = "status_yellow"
	}
	local statuscolour = statusmap[status] or "status_working"
	local update = pid and {pid} or data.gui
	for _,pid in pairs(update) do
		local gui = game.players[pid].gui.relative['drone-port-stats']
		if gui then
			gui = gui.content.status_flow
			gui.icon.sprite = "utility/"..statuscolour
			gui.status.caption = {"gui.drone-status-"..status, delay}
		end
	end
end
local function updateTravelStatsGui(source, destination, stats_table)
	if not destination then
		stats_table.stat_distance.caption = {"gui.drone-stats-na"}
		stats_table.stat_time.caption = {"gui.drone-stats-na"}
		stats_table.stat_batteries.caption = {"gui.drone-stats-na"}
		stats_table.stat_throughput.caption = {"gui.drone-stats-na"}
	else
		local distance = math2d.position.distance(source.position, destination.position)
		distance_r = math.floor(distance/10)/100 -- km to 2 decimal places
		local travel_time = distance*2 / 67.9 + 5 -- measured 67.9m/s movement speed, try to get real value here
		local batteries = travel_time / 15 + 4 -- 1 battery lasts 15 seconds - should really use values from prototypes but whatever
		local total_time = travel_time + 100 -- 25 seconds each for takeoff and landing at source and destination
		local time_r = math.floor(total_time)
		local throughput = 9 / (total_time/60) -- stacks per minute
		local throughput_r = math.floor(throughput*100)/100 -- truncate to 2 decimal places
		stats_table.stat_distance.caption = {"gui.drone-stats-distance-value", distance_r}
		stats_table.stat_time.caption = {"gui.drone-stats-time-value", math.floor(time_r/60), time_r%60<10 and "0" or "", time_r%60}
		stats_table.stat_batteries.caption = {"gui.drone-stats-batteries-value", math.ceil(batteries)}
		stats_table.stat_throughput.caption = {"gui.drone-stats-throughput-value", throughput_r}
	end
end

local function checkRangeForTabs(player, gui, base, fuel, export, import)
	if not (gui and gui.valid) then return end
	for i,obj in pairs({base,fuel,export,import}) do
		local reach = player.can_reach_entity(obj)
		local tab = gui.tabs[i].tab
		tab.enabled = reach
		if reach then tab.tooltip = "" else tab.tooltip = {"cant-reach"} end
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
						gui = event.entity.name == base and defines.relative_gui_type.electric_energy_interface_gui or defines.relative_gui_type.container_gui,
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
				tab = event.entity.name == base and 1 or 2
			end
			gui['drone-port-tabs'].selected_tab_index = tab
			checkRangeForTabs(player, gui['drone-port-tabs'], data.base, data.fuel, data.export, data.import)

			if event.entity.name == base and not gui['drone-port-stats'] then
				table.insert(data.gui, player.index)
				local frame = gui.add{
					type = "frame",
					name = "drone-port-stats",
					anchor = {
						gui = defines.relative_gui_type.electric_energy_interface_gui,
						position = defines.relative_gui_position.bottom,
						name = base
					},
					direction = "vertical",
					style = "inner_frame_in_outer_frame"
				}
				frame.style.use_header_filler = false
				local title_flow = frame.add{type = "flow", name = "title_flow"}
				local name_flow = title_flow.add{type = "flow", name = "name_flow"}
				name_flow.add{type = "label", caption = data.name, style = "frame_title"}
				name_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/rename_icon_small_white", name = "drone-port-rename-button"}
				local rename_flow = title_flow.add{type = "flow", name = "rename_flow", visible = false}
				rename_flow.add{type = "textfield", text = data.name, lose_focus_on_confirm = true, name = "drone-port-rename-input"}
				rename_flow.add{
					type = "sprite-button",
					name = "drone-port-rename-confirm",
					style = "tool_button_green",
					tooltip = {"gui.confirm"},
					sprite = "utility/check_mark_white"
				}
				rename_flow.add{
					type = "sprite-button",
					name = "drone-port-rename-cancel",
					style = "tool_button_red",
					tooltip = {"gui.dear-wube-cancel-means-cancel-not-back-thank-you-very-much"},
					sprite = "utility/close_black"
				}
				
				local inner = frame.add{
					type = "frame",
					name = "content",
					style = "inside_shallow_frame_with_padding",
					direction = "vertical"
				}
				local status_flow = inner.add{type = "flow", style = "status_flow", name = "status_flow"}
				status_flow.style.vertical_align = "center"
				status_flow.style.bottom_margin = 12
				status_flow.add{
					type = "sprite",
					style = "status_image",
					name = "icon"
				}
				status_flow.add{
					type = "label",
					name = "status"
				}
				updateStatusGui(data, player.index)

				local destination_flow = inner.add{type = "flow", name = "destination_flow"}
				destination_flow.add{
					type = "label",
					style = "caption_label",
					caption = {"gui.drone-destination"}
				}
				destination_flow.style.vertical_align = "center"
				local destination = (data.queued_target and data.queued_target ~= "DEQUEUE" and data.queued_target.valid and getStruct(data.queued_target)) or (data.target and data.target.valid and getStruct(data.target)) or nil
				destination_flow.add{
					type = "label",
					name = "destination_name",
					caption = destination and destination.name or {"gui.drone-destination-not-set"}
				}.style.maximal_width = 300
				destination_flow.add{
					type = "sprite-button",
					name = "drone-port-open-destination-search",
					style = "tool_button",
					sprite = "utility/change_recipe",
					tooltip = {"gui.drone-destination-select"}
				}
				if player.force.technologies['mam-quartz-frequency-mapping'].researched then
					destination_flow.add{
						type = "sprite-button",
						name = "drone-port-open-destination-on-map",
						style = "tool_button",
						sprite = "utility/map",
						tooltip = {"gui-train.open-in-map"}
					}
				end

				local search_flow = inner.add{type = "flow", direction = "vertical", name = "search_flow", visible = false}
				search_flow.style.maximal_width = 300
				local s = search_flow.add{
					type = "textfield",
					name = "drone-port-destination-search",
					lose_focus_on_confirm = true
				}
				s.style.maximal_width = 300
				s.style.horizontally_stretchable = true
				s = search_flow.add{
					type = "list-box",
					name = "drone-port-destination-selection",
					style = "list_box_in_shallow_frame"
				}
				s.tags = {['search-ids'] = {}}
				s.style.height = 120
				s.style.maximal_width = 300
				s.style.horizontally_stretchable = true
				s = search_flow.add{
					type = "label",
					caption = {"gui.drone-destination-update-on-takeoff"}
				}
				s.style.single_line = false

				local stats_table = inner.add{type = "table", style = "bordered_table", column_count = 4, name = "stats_table"}
				stats_table.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-distance"}}
				stats_table.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-time"}}
				stats_table.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-batteries"}}
				stats_table.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-throughput"}}
				stats_table.add{type = "label", name = "stat_distance", caption = {"gui.drone-stats-na"}}
				stats_table.add{type = "label", name = "stat_time", caption = {"gui.drone-stats-na"}}
				stats_table.add{type = "label", name = "stat_batteries", caption = {"gui.drone-stats-na"}}
				stats_table.add{type = "label", name = "stat_throughput", caption = {"gui.drone-stats-na"}}
				if destination then
					updateTravelStatsGui(data.base, destination.base, stats_table)
				end
			end
		end
	end
end
local function onMove(event)
	-- update tab enabled state based on reach
	local player = game.players[event.player_index]
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local entity = player.opened
	if entity.name ~= base and entity.name ~= storage and entity.name ~= fuelbox then return end
	local floor = entity.surface.find_entity(base, entity.position)
	local data = getStruct(floor)
	local gui = player.gui.relative
	checkRangeForTabs(player, gui['drone-port-tabs'], data.base, data.fuel, data.export, data.import)
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and event.entity.valid then
		local player = game.players[event.player_index]
		if event.entity.name == base or event.entity.name == storage or event.entity.name == fuelbox then
			local gui = player.gui.relative['drone-port-tabs']
			if gui then gui.destroy() end
			gui = player.gui.relative['drone-port-stats']
			if gui then gui.destroy() end
		end
		if event.entity.name == base then
			local data = getStruct(event.entity)
			for i,pid in pairs(data.gui) do
				if pid == player.index then
					table.remove(data.gui, i)
					break
				end
			end
		end
	end
end
local function onGuiClick(event)
	if not event.element.valid then return end
	local player = game.players[event.player_index]
	local opened = player.opened
	if event.element.name == "drone-port-rename-button" then
		local name_flow = event.element.parent
		local title_flow = name_flow.parent
		local rename_flow = title_flow.rename_flow
		name_flow.visible = false
		rename_flow.visible = true
		rename_flow.children[1].focus()
	elseif event.element.name == "drone-port-rename-confirm" then
		local rename_flow = event.element.parent
		local title_flow = rename_flow.parent
		local name_flow = title_flow.name_flow
		local newname = rename_flow.children[1].text
		if newname ~= "" then
			local data = getStruct(player.opened)
			name_flow.children[1].caption = newname
			data.name = newname
			renamePortTag(data.base, newname)
			if data.drone then
				data.drone.entity_label = newname
			end
		else
			rename_flow.children[1].text = name_flow.children[1].caption
		end
		name_flow.visible = true
		rename_flow.visible = false
	elseif event.element.name == "drone-port-rename-cancel" then
		local rename_flow = event.element.parent
		local title_flow = rename_flow.parent
		local name_flow = title_flow.name_flow
		rename_flow.children[1].text = name_flow.children[1].caption
		name_flow.visible = true
		rename_flow.visible = false
	
	elseif event.element.name == "drone-port-open-destination-search" then
		local destination_flow = event.element.parent
		local inner_frame = destination_flow.parent
		local search_flow = inner_frame.search_flow
		search_flow.visible = not search_flow.visible
		inner_frame.stats_table.visible = not search_flow.visible
	elseif event.element.name == "drone-port-open-destination-on-map" then
		local data = getStruct(player.opened)
		local target = (data.queued_target and data.queued_target ~= "DEQUEUE" and data.queued_target.valid and getStruct(data.queued_target)) or (data.target and data.target.valid and getStruct(data.target)) or nil
		if target then
			player.open_map(target.base.position)
			player.opened = nil
		end
	end
end
local function onGuiConfirm(event)
	if not event.element.valid then return end
	local player = game.players[event.player_index]
	local opened = player.opened
	if event.element.name == "drone-port-rename-input" then
		local rename_flow = event.element.parent
		local title_flow = rename_flow.parent
		local name_flow = title_flow.name_flow
		local newname = rename_flow.children[1].text
		if newname ~= "" then
			local data = getStruct(player.opened)
			name_flow.children[1].caption = newname
			data.name = newname
			renamePortTag(data.base, newname)
			if data.drone then
				data.drone.entity_label = newname
			end
		else
			rename_flow.children[1].text = name_flow.children[1].caption
		end
		name_flow.visible = true
		rename_flow.visible = false
	
	elseif event.element.name == "drone-port-destination-search" then
		local search_flow = event.element.parent
		local inner_frame = search_flow.parent
		local destination_flow = inner_frame.destination_flow
		-- grab top search result and set destination
		local search_box = search_flow['drone-port-destination-selection']
		local first_result = search_box.tags['search-ids'][1]
		local data = getStruct(player.opened)
		local target = first_result and getStructById(first_result)
		if target then
			data.queued_target = target.base
			destination_flow.destination_name.caption = target.name
			updateTravelStatsGui(data, target, inner_frame.stats_table)
		else
			data.queued_target = "DEQUEUE"
			destination_flow.destination_name.caption = {"gui.drone-destination-not-set"}
			updateTravelStatsGui(data, nil, inner_frame.stats_table)
		end
		search_flow.visible = false
		inner_frame.stats_table.visible = true
	end
end
local function onGuiTextChange(event)
	if not event.element.valid then return end
	local player = game.players[event.player_index]
	local opened = player.opened
	if event.element.name == "drone-port-destination-search" then
		local search_flow = event.element.parent
		local inner_frame = search_flow.parent
		local destination_flow = inner_frame.destination_flow
		local search_box = search_flow['drone-port-destination-selection']
		search_box.clear_items()
		local query = event.element.text
		local matches = {}
		for _,subgroup in pairs(script_data.ports) do
			for _,struct in pairs(subgroup) do
				if struct.base ~= opened and string.find(string.lower(struct.name), string.lower(query), 1, true) then
					table.insert(matches, struct)
				end
			end
		end
		table.sort(matches, function(a,b)
			if a.name == b.name then
				return a.base.unit_number < b.base.unit_number
			else
				return a.name < b.name
			end
		end)
		local ids = {}
		for _,struct in pairs(matches) do
			table.insert(ids, struct.base.unit_number)
			search_box.add_item(struct.name)
		end
		search_box.tags = {['search-ids'] = ids}
	end
end
local function onGuiSelectionChange(event)
	if not event.element.valid then return end
	local player = game.players[event.player_index]
	local opened = player.opened
	if event.element.name == "drone-port-destination-selection" then
		local search_flow = event.element.parent
		local inner_frame = search_flow.parent
		local destination_flow = inner_frame.destination_flow
		-- grab top search result and set destination
		local result = event.element.tags['search-ids'][event.element.selected_index]
		local data = getStruct(player.opened)
		local target = result and getStructById(result)
		if target then
			data.queued_target = target.base
			destination_flow.destination_name.caption = target.name
		else
			data.queued_target = "DEQUEUE"
			destination_flow.destination_name.caption = {"gui.drone-destination-not-set"}
		end
		updateTravelStatsGui(data.base, target.base, inner_frame.stats_table)
		search_flow.visible = false
		inner_frame.stats_table.visible = true
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
		local state = struct.state
		local guests = struct.guests
		if drone and drone.autopilot_destination and not drone.burner.currently_burning and not drone.burner.inventory[1].valid_for_read then
			for _,player in pairs(drone.force.players) do
				player.add_alert(drone, defines.alert_type.train_out_of_fuel)
			end
		end
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
				if struct.queued_target then
					if struct.queued_target == "DEQUEUE" then
						struct.target = nil
						destination = nil
					elseif struct.queued_target.valid then
						struct.target = struct.queued_target
						destination = struct.target
					end
					struct.queued_target = nil
				end
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
					local distance = math2d.position.distance(station.position, destination.position)
					local travel_time = distance*2 / 67.9 + 5 -- measured 67.9m/s movement speed, try to get real value here
					local batteries = travel_time / 15 + 4 -- 1 battery lasts 15 seconds - should really use values from prototypes but whatever
					if not fueltarget.is_empty() and fueltarget[1].count >= batteries then
						-- consume base 4 batteries per trip
						fueltarget[1].count = fueltarget[1].count - 4
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
					if not struct.sticker then
						struct.sticker = drone.surface.create_entity{
							name = sticker,
							target = drone,
							force = drone.force,
							position = drone.position
						}
						struct.sticker.active = false
					end
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
						state.delay = event.tick + (script_data.drone_demo and 5 or 25)*60
						drone.autopilot_destination = destination.position
					else
						drone.autopilot_destination = math2d.position.add(
							destination.position,
							math2d.position.rotate_vector({0,-8}, (qpos-1)/#ddata.guests*360)
						)
					end
				end
			elseif state.status == "arriving" then
				if not (destination and destination.valid) then
					-- destination destroyed, return home
					state.status = "emergency-recall"
					drone.autopilot_destination = station.position
				else
					drone.autopilot_destination = destination.position
					if event.tick > state.delay then
						state.status = "unloading"
					end
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
							state.delay = event.tick + (script_data.drone_demo and 1 or 25)*60
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
					if not struct.sticker then
						struct.sticker = drone.surface.create_entity{
							name = sticker,
							target = drone,
							force = drone.force,
							position = drone.position
						}
						struct.sticker.active = false
					end
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
					drone.autopilot_destination = station.position
				else
					drone.autopilot_destination = math2d.position.add(
						station.position,
						math2d.position.rotate_vector({0,-8}, (qpos-1)/#guests*360)
					)
				end
			elseif state.status == "landing" then
				drone.autopilot_destination = station.position
				if event.tick > state.delay then
					state.status = "loading"
				end
			elseif state.status == "emergency-arrival" then
				-- register arrival into the destination queue
				table.insert(guests, drone)
				state.status = "waiting-to-emergency-arrive"
			elseif state.status == "waiting-to-emergency-arrive" then
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
						math2d.position.rotate_vector({0,-8}, (qpos-1)/#guests*360)
					)
				end
			elseif state.status == "emergency-landing" then
				drone.autopilot_destination = station.position
				if event.tick > state.delay then
					state.status = "waiting-for-destination" -- skip loading phase
				end
			else
				error("Unknown drone status "..state.status)
			end
		end
		updateStatusGui(struct)
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
		-- clear speed sticker
		if data.sticker then
			data.sticker.destroy()
			data.sticker = nil
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

local function onFastTransfer(event, half)
	local player = game.players[event.player_index]
	local target = player.selected
	if not (target and target.valid and target.name == base) then return end
	local data = getStruct(target)
	if not data then return end
	if player.cursor_stack.valid_for_read then
		-- if the player is holding batteries, try putting them in the fuel box
		if player.cursor_stack.name == "battery" then
			if fastTransfer(player, data.fuel, half) then return end
		end
		-- otherwise, or if it can't go in the fuel box, put it in export
		fastTransfer(player, data.export, half)
	else
		-- retrieve items from import, or from export, or from fuel box - whichever is the first successful one
		if not fastTransfer(player, data.import, half) then
			if not fastTransfer(player, data.export, half) then
				fastTransfer(player, data.fuel, half)
			end
		end
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
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_confirmed] = onGuiConfirm,
		[defines.events.on_gui_text_changed] = onGuiTextChange,
		[defines.events.on_gui_selection_state_changed] = onGuiSelectionChange,
		[defines.events.on_gui_selected_tab_changed] = onGuiTabChange,
		[defines.events.on_player_changed_position] = onMove,
		
		[defines.events.on_player_configured_spider_remote] = onSetupSpiderRemote,
		[defines.events.on_spider_command_completed] = onSpiderDone,
		[defines.events.on_tick] = onTick,

		["fast-entity-transfer-hook"] = function(event) onFastTransfer(event, false) end,
		["fast-entity-split-hook"] = function(event) onFastTransfer(event, true) end
	}
}
