---@class DroneStatus
---@field status string
---@field delay uint Tick number to wait until

---@class DroneTravelStats
---@field distance number
---@field time number
---@field batteries number

---@class DronePortData
---@field name string
---@field base LuaEntity ElectricEnergyInterface
---@field stop LuaEntity TrainStop
---@field fuel LuaEntity Container
---@field export LuaEntity Container
---@field import LuaEntity Container
---@field target LuaEntity|nil Target drone port base
---@field queued_target LuaEntity|nil Queued target change, to be applied next time the drone takes off; if set to self.base, target will be cleared
---@field state DroneStatus
---@field drone LuaEntity|nil SpiderVehicle
---@field sticker LuaEntity|nil Speed sticker applied to spider to make it go fast
---@field guests LuaEntity[] Drones - including own drone - queued at this station
---@field gui table<uint,number> List of players who have this drone port's GUI open

---@alias DronePortBucket DronePortData[]

-- uses global.drones.ports to list all ports
-- uses global.drones.drones to map drones back to their port
-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local fastTransfer = require(modpath.."scripts.organisation.containers").fastTransfer
local refundEntity = require(modpath.."scripts.lualib.building-management").refundEntity
local link = require(modpath.."scripts.lualib.linked-entity")
local math2d = require("math2d")

local is_demo = script.level.is_simulation

local base = "drone-port"
local stop = base.."-stop"
local storage = base.."-box"
local storage_pos_out = {-2.5,-1.5}
local storage_pos_in = {2.5,-1.5}
local fuelbox = base.."-fuelbox"
local fuelbox_pos = {-3.5,3.5}
local vehicle = "drone"
local sticker = vehicle.."-speed-sticker"

local debounce_error = {}
---@class global.drones
---@field ports DronePortBucket[] indexed by the port, grouped by bucket
---@field drones DronePortData[] indexed by the drone
---@field drone_demo boolean|nil If set, drones take off and land super fast - used for menu sim demo
local script_data = {
	ports = {},
	drones = {}
}
local buckets = 30
for i=0,buckets-1 do script_data.ports[i] = {} end
local function getBucket(tick)
	return script_data.ports[tick%buckets]
end
---@param struct DronePortData
local function registerStruct(struct)
	script_data.ports[struct.base.unit_number%buckets][struct.base.unit_number] = struct
end
---@param struct DronePortData
local function registerDrone(struct)
	script_data.drones[struct.drone.unit_number] = struct
end
---@param id uint
local function getStructById(id)
	return script_data.ports[id%buckets][id]
end
---@param floor LuaEntity
local function getStruct(floor)
	return getStructById(floor.unit_number)
end
---@param gui LuaGuiElement
local function getStructFromGui(gui)
	return getStructById(gui.tags['port-number'])
end
---@param drone LuaEntity
local function getStructFromDrone(drone)
	return script_data.drones[drone.unit_number]
end
---@param floor LuaEntity
local function clearStruct(floor)
	local struct = getStruct(floor)
	for pid in pairs(struct.gui) do
		game.players[pid].opened = nil
	end
	script_data.ports[floor.unit_number%buckets][floor.unit_number] = nil
end
---@param drone LuaEntity
local function clearStructFromDrone(drone)
	script_data.drones[drone.unit_number] = nil
end

---@param event on_build
---@param entity LuaEntity
---@param reason LocalisedString
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

---@param data DronePortData
local function renamePortTag(data)
	data.stop.backer_name = "[img=entity.drone-port] "..data.name
	if data.drone then
		data.drone.entity_label = data.name
	end
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		local station = entity.surface.create_entity{
			name = stop,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
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
		link.register(entity, station)
		link.register(entity, store1)
		link.register(entity, store2)
		link.register(entity, fuel)
		io.addConnection(entity, {-3.5,5.5}, "input", fuel)
		io.addConnection(entity, {1.5,5.5}, "input", store1)
		io.addConnection(entity, {3.5,5.5}, "output", store2, defines.direction.south)
		entity.rotatable = false

		local name = station.backer_name
		station.backer_name = "[img=entity.drone-port] "..name
		registerStruct{
			name = name,
			base = entity,
			stop = station,
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
	end
	if entity.name == vehicle then
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
		link.register(port, entity)
		entity.teleport(port.position)
		data.drone = entity
		entity.entity_label = data.name
		table.insert(data.guests, entity)
		data.state.status = "loading"
		registerDrone(data)
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		clearStruct(entity)
	end
	if entity.name == vehicle then
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
			clearStructFromDrone(entity)
		end
	end
end

---@param source LuaEntity
---@param destination LuaEntity
---@return DroneTravelStats
local function calculateTravelStats(source, destination)
	if not destination then return end
	local distance = math2d.position.distance(source.position, destination.position)
	local drone_speed = 67.9 -- m/s, measured in-game
	local travel_time = distance*2 / drone_speed + 5
	local batteries = travel_time / 15 + 4 -- 1 battery lasts 15 seconds, plus 4 batteries per round trip
	local total_time = travel_time + 100 -- 25 seconds each for takeoff and landing at source and destination
	return {
		distance = distance,
		time = total_time,
		batteries = batteries
	}
end
---@param data DronePortData
---@param pid uint
local function updateStatusGui(data, pid)
	local status = data.state.status
	local delay = data.state.delay and math.ceil((data.state.delay - game.tick)/60) or 0
	if data.base.energy == 0 then
		status = "no-power"
	elseif data.drone then
		local burner = data.drone.burner
		if data.state.status == "waiting-for-destination" then
			if data.target and data.target.valid then
				-- ensure drone has sufficient batteries to take off
				local stats = calculateTravelStats(data.base, data.target)
				local fuelstack = burner.inventory[1]
				if not fuelstack.valid_for_read or fuelstack.count <= stats.batteries then
					status = "out-of-batteries"
				end
			end
		else
			-- at any other time, ensure drone actually has batteries
			if not burner.currently_burning and burner.inventory.is_empty() then
				status = "out-of-batteries"
			end
		end
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
	local update = pid and {[pid]=0} or data.gui
	for pid in pairs(update) do
		local gui = (game.players[pid].gui.screen['drone-port-container'] or {})['drone-port-stats']
		if gui then
			gui = gui.content.status_flow
			gui.icon.sprite = "utility/"..statuscolour
			gui.status.caption = {"gui.drone-status-"..status, delay}
		end
	end
end
---@param source LuaEntity
---@param destination LuaEntity
---@param stats_table LuaGuiElement
local function updateTravelStatsGui(source, destination, stats_table)
	if not destination then
		stats_table['stat_distance'].label.caption = {"gui.drone-stats-na"}
		stats_table['stat_time'].label.caption = {"gui.drone-stats-na"}
		stats_table['stat_batteries'].label.caption = {"gui.drone-stats-na"}
		stats_table['stat_throughput'].label.caption = {"gui.drone-stats-na"}
	else
		local stats = calculateTravelStats(source, destination)
		local distance = math.floor(stats.distance/10)/100 -- km to 2 decimal places
		local time = math.floor(stats.time)
		local throughput = math.floor(9 / (stats.time/60) * 100) / 100 -- stacks per minute, to 2 decimal places
		stats_table['stat_distance'].label.caption = {"gui.drone-stats-distance-value", distance}
		stats_table['stat_time'].label.caption = {"gui.drone-stats-time-value", math.floor(time/60), time%60<10 and "0" or "", time%60}
		stats_table['stat_batteries'].label.caption = {"gui.drone-stats-batteries-value", math.ceil(stats.batteries)}
		stats_table['stat_throughput'].label.caption = {"gui.drone-stats-throughput-value", throughput}
	end
end

---@param player LuaPlayer
---@param gui LuaGuiElement
---@param port LuaEntity
---@param fuel LuaEntity
---@param export LuaEntity
---@param import LuaEntity
local function checkRangeForTabs(player, gui, port, fuel, export, import)
	if not (gui and gui.valid) then return end
	for i,obj in pairs({port,fuel,export,import}) do
		local reach = player.can_reach_entity(obj)
		local tab = gui.tabs[i].tab
		tab.enabled = reach
		if reach then tab.tooltip = "" else tab.tooltip = {"cant-reach"} end
	end
end
---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.valid then
		if event.entity.name == base then
			local data = getStruct(event.entity)
			player.opened = data.stop
		end

		if event.entity.name == storage or event.entity.name == fuelbox then
			local floor = event.entity.surface.find_entity(base, event.entity.position)
			local data = getStruct(floor)
			local gui = player.gui.relative
			-- create fake tabs for switching to the fuel crate
			if not gui['drone-port-tabs'] then
				local tabs = gui.add{
					type = "tabbed-pane",
					name = "drone-port-tabs",
					anchor = {
						gui = defines.relative_gui_type.container_gui,
						position = defines.relative_gui_position.top,
						names = {storage, fuelbox}
					},
					style = "tabbed_pane_with_no_side_padding_and_tabs_hidden"
				}
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-drone"}},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-fuel-box"}},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-export"}},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-import"}},
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
			checkRangeForTabs(player, gui['drone-port-tabs'], data.stop, data.fuel, data.export, data.import)
		end

		if event.entity.name == stop then
			local floor = event.entity.surface.find_entity(base, event.entity.position)
			local data = getStruct(floor)
			local gui = player.gui.screen
			data.gui[player.index] = 0
			local destination = (data.queued_target and data.queued_target ~= data.base and data.queued_target.valid and getStruct(data.queued_target))
				or (data.target and data.target.valid and getStruct(data.target))
				or nil
			if not gui['drone-port-container'] then
				local secret_flow = gui.add{
					type = "frame",
					name = "drone-port-container",
					direction = "vertical",
					style = "invisible_frame",
					tags = {["port-number"] = data.base.unit_number}
				}
				local tabs = secret_flow.add{
					type = "tabbed-pane",
					name = "drone-port-tabs",
					style = "tabbed_pane_with_no_side_padding_and_tabs_hidden"
				}
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-drone"}},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-fuel-box"}},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-export"}},
					tabs.add{type="empty-widget"}
				)
				tabs.add_tab(
					tabs.add{type = "tab", caption = {"gui.station-import"}},
					tabs.add{type="empty-widget"}
				)

				local frame = secret_flow.add{
					type = "frame",
					name = "drone-port-stats",
					direction = "vertical",
					style = "inner_frame_in_outer_frame"
				}

				local title_flow = frame.add{type = "flow", name = "title_flow"}
				local name_flow = title_flow.add{type = "flow", name = "name_flow"}
				name_flow.drag_target = secret_flow
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
				local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
				pusher.style.height = 24
				pusher.style.horizontally_stretchable = true
				pusher.drag_target = secret_flow
				title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "drone-port-close"}

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

				local minimap_flow = inner.add{type = "flow", direction = "horizontal", name = "minimap_flow"}
				minimap_flow.add{type = "empty-widget"}.style.horizontally_stretchable = true
				local minimap_frame = minimap_flow.add{
					type = "frame",
					name = "minimap_frame",
					style = "deep_frame_in_shallow_frame"
				}
				minimap_frame.add{
					type = "minimap",
					name = "drone-port-minimap",
					position = data.drone and data.drone.position or data.base.position,
					surface_index = data.base.surface.index,
					tooltip = {"gui-train.open-in-map"}
				}
				minimap_flow.add{type = "empty-widget"}.style.horizontally_stretchable = true
				minimap_flow.visible = player.minimap_enabled

				local destination_flow = inner.add{type = "flow", name = "destination_flow"}
				destination_flow.style.top_margin = 12
				destination_flow.style.bottom_margin = 12
				destination_flow.add{
					type = "label",
					style = "caption_label",
					caption = {"gui.drone-destination"}
				}
				destination_flow.style.vertical_align = "center"
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
				if player.minimap_enabled then
					destination_flow.add{
						type = "sprite-button",
						name = "drone-port-open-destination-on-map",
						style = "tool_button",
						sprite = "utility/map",
						tooltip = {"gui-train.open-in-map"}
					}
				end

				local search_flow = inner.add{type = "flow", direction = "vertical", name = "search_flow", visible = false}
				local s = search_flow.add{
					type = "textfield",
					name = "drone-port-destination-search",
					lose_focus_on_confirm = true
				}
				s.style.maximal_width = 0
				s.style.horizontally_stretchable = true
				s = search_flow.add{
					type = "list-box",
					name = "drone-port-destination-selection",
					style = "list_box_in_shallow_frame"
				}
				s.tags = {['search-ids'] = {}}
				s.style.height = 120
				s.style.horizontally_stretchable = true
				s = search_flow.add{
					type = "label",
					caption = {"gui.drone-destination-update-on-takeoff"}
				}
				s.style.single_line = false

				local stats_table = inner.add{type = "flow", direction = "vertical", name = "stats_table"}
				local flow = stats_table.add{type = "flow", direction = "horizontal", name = "stat_distance"}
				flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-distance"}}
				flow.add{type = "label", name = "label", caption = {"gui.drone-stats-na"}}

				flow = stats_table.add{type = "flow", direction = "horizontal", name = "stat_time"}
				flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-time"}}
				flow.add{type = "label", name = "label", caption = {"gui.drone-stats-na"}}

				flow = stats_table.add{type = "flow", direction = "horizontal", name = "stat_batteries"}
				flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-batteries"}}
				flow.add{type = "label", name = "label", caption = {"gui.drone-stats-na"}}
				flow.add{type = "label", caption = "[img=info]", tooltip = {"gui.drone-stats-batteries-info"}}

				flow = stats_table.add{type = "flow", direction = "horizontal", name = "stat_throughput"}
				flow.add{type = "label", style = "caption_label", caption = {"gui.drone-stats-throughput"}}
				flow.add{type = "label", name = "label", caption = {"gui.drone-stats-na"}}
			else
				local container = gui['drone-port-container']
				container.visible = true
				container.tags = {["port-number"] = data.base.unit_number}
				local frame = gui['drone-port-container']['drone-port-stats']
				-- status and statistics are updated below, just leaving the name and destination elements to be updated here
				local title_flow = frame.title_flow
				local name_flow = title_flow.name_flow
				name_flow.children[1].caption = data.name
				local rename_flow = title_flow.rename_flow
				rename_flow.children[1].text = data.name

				local inner = frame.content
				inner.minimap_flow.minimap_frame['drone-port-minimap'].entity = data.drone or data.base
				inner.minimap_flow.visible = player.minimap_enabled
				local destination_flow = inner.destination_flow
				destination_flow.destination_name.caption = destination and destination.name or {"gui.drone-destination-not-set"}
				if player.minimap_enabled and not destination_flow['drone-port-open-destination-on-map'] then
					destination_flow.add{
						type = "sprite-button",
						name = "drone-port-open-destination-on-map",
						style = "tool_button",
						sprite = "utility/map",
						tooltip = {"gui-train.open-in-map"}
					}
				end
			end
			player.opened = gui['drone-port-container']
			updateStatusGui(data, player.index)
			updateTravelStatsGui(data.base, destination and destination.base, gui['drone-port-container']['drone-port-stats'].content.stats_table)
			gui['drone-port-container']['drone-port-tabs'].selected_tab_index = 1
			checkRangeForTabs(player, gui['drone-port-container']['drone-port-tabs'], data.stop, data.fuel, data.export, data.import)
			gui['drone-port-container'].force_auto_center()
		end
	end
end
---@param event on_player_changed_position
local function onMove(event)
	-- update tab enabled state based on reach
	local player = game.players[event.player_index]
	local data
	if player.opened_gui_type == defines.gui_type.custom and player.opened.name == "drone-port-container" then
		data = getStructFromGui(player.opened)
		checkRangeForTabs(player, player.gui.screen['drone-port-container']['drone-port-tabs'], data.stop, data.fuel, data.export, data.import)
	elseif player.opened_gui_type == defines.gui_type.entity and (player.opened.name == storage or player.opened.name == fuelbox) then
		local floor = player.opened.surface.find_entity(base, player.opened.position)
		data = getStruct(floor)
		checkRangeForTabs(player, player.gui.relative['drone-port-tabs'], data.stop, data.fuel, data.export, data.import)
	end
end
---@param event on_gui_closed
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.custom and event.element.valid and event.element.name == "drone-port-container" then
		local player = game.players[event.player_index]
		local data = getStructFromGui(event.element)
		data.gui[player.index] = nil
		event.element.visible = false
	end
end
---@param event on_gui_click
local function onGuiClick(event)
	if not event.element.valid then return end
	local player = game.players[event.player_index]
	if event.element.name == "drone-port-close" then
		player.opened = nil
	elseif event.element.name == "drone-port-rename-button" then
		local name_flow = event.element.parent
		local title_flow = name_flow.parent
		local rename_flow = title_flow['rename_flow']
		name_flow.visible = false
		rename_flow.visible = true
		rename_flow.children[1].focus()
	elseif event.element.name == "drone-port-rename-confirm" then
		local rename_flow = event.element.parent
		local title_flow = rename_flow.parent
		local name_flow = title_flow['name_flow']
		local newname = rename_flow.children[1].text
		if newname ~= "" then
			local data = getStructFromGui(player.opened)
			name_flow.children[1].caption = newname
			data.name = newname
			renamePortTag(data)
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
		local name_flow = title_flow['name_flow']
		rename_flow.children[1].text = name_flow.children[1].caption
		name_flow.visible = true
		rename_flow.visible = false

	elseif event.element.name == "drone-port-open-destination-search" then
		local destination_flow = event.element.parent
		local inner_frame = destination_flow.parent
		local search_flow = inner_frame['search_flow']
		search_flow.visible = not search_flow.visible
		inner_frame['stats_table'].visible = not search_flow.visible
	elseif event.element.name == "drone-port-open-destination-on-map" then
		local data = getStructFromGui(player.opened)
		local target = (data.queued_target and data.queued_target ~= data.base and data.queued_target.valid and getStruct(data.queued_target)) or (data.target and data.target.valid and getStruct(data.target)) or nil
		if target then
			player.open_map(target.base.position)
			player.opened = nil
		end
	elseif event.element.name == "drone-port-minimap" then
		local data = getStructFromGui(player.opened)
		player.open_map((data.drone or data.base).position)
		player.opened = nil
	end
end
---@param event on_gui_confirmed
local function onGuiConfirm(event)
	if not event.element.valid then return end
	local player = game.players[event.player_index]
	if event.element.name == "drone-port-rename-input" then
		local rename_flow = event.element.parent
		local title_flow = rename_flow.parent
		local name_flow = title_flow['name_flow']
		local newname = rename_flow.children[1].text
		if newname ~= "" then
			local data = getStructFromGui(player.opened)
			name_flow.children[1].caption = newname
			data.name = newname
			renamePortTag(data)
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
		local destination_flow = inner_frame['destination_flow']
		local stats_table = inner_frame['stats_table']
		-- grab top search result and set destination
		local search_box = search_flow['drone-port-destination-selection']
		local first_result = search_box.tags['search-ids'][1]
		local data = getStructFromGui(player.opened)
		local target = first_result and getStructById(first_result)
		if target then
			data.queued_target = target.base
			destination_flow.destination_name.caption = target.name
			updateTravelStatsGui(data, target, stats_table)
		else
			data.queued_target = data.base
			destination_flow.destination_name.caption = {"gui.drone-destination-not-set"}
			updateTravelStatsGui(data, nil, stats_table)
		end
		search_flow.visible = false
		stats_table.visible = true
	end
end
---@param event on_gui_text_changed
local function onGuiTextChange(event)
	if not event.element.valid then return end
	if event.element.name == "drone-port-destination-search" then
		local player = game.players[event.player_index]
		local opened = getStructFromGui(player.opened)
		local search_flow = event.element.parent
		local search_box = search_flow['drone-port-destination-selection']
		search_box.clear_items()
		local query = event.element.text
		if query ~= "" then
			local matches = {}
			for _,subgroup in pairs(script_data.ports) do
				for _,struct in pairs(subgroup) do
					if struct.base ~= opened.base and string.find(string.lower(struct.name), string.lower(query), 1, true) then
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
		else
			search_box.tags = {['search-ids'] = {}}
		end
	end
end
---@param event on_gui_selection_state_changed
local function onGuiSelectionChange(event)
	if not event.element.valid then return end
	local player = game.players[event.player_index]
	if event.element.name == "drone-port-destination-selection" then
		local search_flow = event.element.parent
		local inner_frame = search_flow.parent
		local destination_flow = inner_frame['destination_flow']
		local stats_table = inner_frame['stats_table']
		-- grab top search result and set destination
		local result = event.element.tags['search-ids'][event.element.selected_index]
		local data = getStructFromGui(player.opened)
		local target = result and getStructById(result)
		if target then
			data.queued_target = target.base
			destination_flow.destination_name.caption = target.name
		else
			data.queued_target = data.base
			destination_flow.destination_name.caption = {"gui.drone-destination-not-set"}
		end
		updateTravelStatsGui(data.base, target.base, stats_table)
		search_flow.visible = false
		stats_table.visible = true
	end
end

---@param event on_gui_selected_tab_changed
local function onGuiTabChange(event)
	if event.element.valid and event.element.name == "drone-port-tabs" then
		local player = game.players[event.player_index]
		local data
		if player.opened_gui_type == defines.gui_type.custom and player.opened.name == "drone-port-container" then
			data = getStructFromGui(player.opened)
		elseif player.opened_gui_type == defines.gui_type.entity and (player.opened.name == storage or player.opened.name == fuelbox) then
			local floor = player.opened.surface.find_entity(base, player.opened.position)
			data = getStruct(floor)
		else
			return
		end
		local indexed_parts = {data.stop, data.fuel, data.export, data.import}
		player.opened = indexed_parts[event.element.selected_tab_index]
	end
end

---@param source LuaInventory
---@param target LuaInventory
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

-- load batteries and return if enough were loaded
---@param struct DronePortData
---@param source LuaEntity Fuel box to pull from (may be source or destination box)
---@return boolean
local function loadBatteriesIntoDrone(struct, source)
	local fuelstore = source.get_inventory(defines.inventory.chest)
	local fuelstack = fuelstore[1]
	local fueltarget = struct.drone.burner.inventory
	local targetstack = fueltarget[1]
	local required = math.ceil(calculateTravelStats(struct.base, struct.target).batteries)
	if fuelstack.valid_for_read and fueltarget.can_insert(fuelstack) then
		local wanted = required + 1 - (targetstack.valid_for_read and targetstack.count or 0)
		if wanted > 0 then
			local inserted = fueltarget.insert{name=fuelstack.name, count=wanted}
			fuelstore.remove{name=fuelstack.name, count=inserted}
		end
	end

	return not fueltarget.is_empty() and targetstack.count > required
end

---@param struct DronePortData
local function applySpeedSticker(struct)
	if not struct.sticker then
		local drone = struct.drone
		struct.sticker = struct.drone.surface.create_entity{
			name = sticker,
			force = drone.force,
			position = drone.position,
			target = drone
		}
		-- effect still applies but time-to-live doesn't tick down when inactive. Weird, I know...
		struct.sticker.active = false
	end
end
---@param struct DronePortData
local function removeSpeedSticker(struct)
	if struct.sticker and struct.sticker.valid then
		struct.sticker.destroy()
	end
	struct.sticker = nil
end

---@param struct DronePortData
local function checkIfDroneRanOutOfFuel(struct)
	local drone = struct.drone
	if not (drone and drone.autopilot_destination) then return end
	local burner = drone.burner
	if burner.currently_burning or not burner.inventory.is_empty() then return end
	for _,player in pairs(drone.force.players) do
		player.add_alert(drone, defines.alert_type.train_out_of_fuel)
	end
end

---@param struct DronePortData
local function assertValidDestination(struct)
	if not (struct.target and struct.target.valid) then
		-- destination destroyed, return home
		struct.state = {status = "emergency-recall"}
		struct.drone.autopilot_destination = struct.base.position
		return false
	end
	return true
end

---@param queue LuaEntity[]
---@param drone LuaEntity
local function getDronePositionInQueue(queue, drone)
	for i,test in pairs(queue) do
		if test == drone then return i end
	end
end

---@type table<string,fun(struct:DronePortData)>
local drone_control_functions = {
	-- do nothing
	["no-drone"] = function() end,

	-- unload stuff from the drone to home port's import box
	---@param struct DronePortData
	["loading"] = function(struct)
		if struct.base.energy > 0 then
			local source = struct.drone.get_inventory(defines.inventory.spider_trunk)
			local target = struct.import.get_inventory(defines.inventory.chest)
			transferInventory(source, target)
			if source.is_empty() then
				struct.state.status = "waiting-for-destination"
			end
		end
	end,

	-- wait for user to set a destination if they haven't already; takeoff when ready
	---@param struct DronePortData
	["waiting-for-destination"] = function(struct)
		-- update queued target, if any
		if struct.queued_target then
			if struct.queued_target == struct.base then
				struct.target = nil
			elseif struct.queued_target.valid then
				struct.target = struct.queued_target
			end
			struct.queued_target = nil
		end

		if not (struct.target and struct.target.valid) then return end
		-- load items from station
		transferInventory(
			struct.export.get_inventory(defines.inventory.chest),
			struct.drone.get_inventory(defines.inventory.spider_trunk)
		)

		if not loadBatteriesIntoDrone(struct, struct.fuel) then return end

		-- consume 4 batteries just for taking off (basically 1 each for takeoff/landing at source/destination)
		local fuelstack = struct.drone.burner.inventory[1] -- will always be valid if we got this far
		fuelstack.count = fuelstack.count - 4
		struct.state = {
			status = "takeoff",
			delay = game.tick + 25*60
		}
	end,

	-- wait for takeoff delay
	---@param struct DronePortData
	["takeoff"] = function(struct)
		if not assertValidDestination(struct) then return end
		if game.tick < struct.state.delay then return end
		-- shift self from queue
		table.remove(struct.guests, 1)

		applySpeedSticker(struct)
		struct.drone.autopilot_destination = struct.target.position

		struct.state.status = "outbound"
	end,

	-- wait for spider command completion
	---@param struct DronePortData
	["outbound"] = function(struct)
		assertValidDestination(struct)
	end,

	-- push arrival into destination queue
	---@param struct DronePortData
	["reached-destination"] = function(struct)
		if not assertValidDestination(struct) then return end
		local ddata = getStruct(struct.target)
		table.insert(ddata.guests, struct.drone)
		struct.state.status = "waiting-to-arrive"
	end,

	-- wait until the drone is first in line
	---@param struct DronePortData
	["waiting-to-arrive"] = function(struct)
		if not assertValidDestination(struct) then return end
		local ddata = getStruct(struct.target)
		local mypos = getDronePositionInQueue(ddata.guests, struct.drone)
		if mypos > 1 then
			struct.drone.autopilot_destination = math2d.position.add(
				struct.target.position,
				math2d.position.rotate_vector({0,-8}, (mypos-1)/#ddata.guests * 360)
			)
		else
			struct.drone.autopilot_destination = struct.target.position
			struct.state = {
				status = "arriving",
				delay = game.tick + (is_demo and 5 or 25) * 60
			}
		end
	end,

	-- keep updating autopilot destination to target to counter over-shooting
	---@param struct DronePortData
	["arriving"] = function(struct)
		if not assertValidDestination(struct) then return end
		struct.drone.autopilot_destination = struct.target.position
		if game.tick > struct.state.delay then
			struct.state.status = "unloading"
		end
	end,

	-- deliver items until empty, then pick up stuff to bring home
	---@param struct DronePortData
	["unloading"] = function(struct)
		if not assertValidDestination(struct) then return end
		local ddata = getStruct(struct.target)
		local source = struct.drone.get_inventory(defines.inventory.spider_trunk)
		local target = ddata.import.get_inventory(defines.inventory.chest)
		transferInventory(source, target)
		if not source.is_empty() then return end

		transferInventory(ddata.export.get_inventory(defines.inventory.chest), source)
		-- pick up batteries if available, but there should already be enough for at least a return trip unless the player screwed with it
		loadBatteriesIntoDrone(struct, ddata.fuel)
		struct.state = {
			status = "leaving",
			delay = game.tick + (is_demo and 1 or 25) * 60
		}
	end,

	-- shift self from destination queue and return home
	---@param struct DronePortData
	["leaving"] = function(struct)
		if not assertValidDestination(struct) then return end
		if game.tick < struct.state.delay then return end
		local ddata = getStruct(struct.target)
		table.remove(ddata.guests, 1)

		applySpeedSticker(struct)
		struct.drone.autopilot_destination = struct.base.position

		struct.state.status = "inbound"
	end,

	-- wait for spider command completed
	["inbound"] = function() end,

	-- push arrival into home queue
	---@param struct DronePortData
	["reached-home"] = function(struct)
		table.insert(struct.guests, struct.drone)
		struct.state.status = "waiting-to-return"
	end,

	-- wait until the drone is first in line
	---@param struct DronePortData
	["waiting-to-return"] = function(struct)
		local mypos = getDronePositionInQueue(struct.guests, struct.drone)
		if mypos > 1 then
			struct.drone.autopilot_destination = math2d.position.add(
				struct.base.position,
				math2d.position.rotate_vector({0,-8}, (mypos-1)/#struct.guests * 360)
			)
		else
			struct.drone.autopilot_destination = struct.base.position
			struct.state = {
				status = "landing",
				delay = game.tick + 25 * 60
			}
		end
	end,

	-- keep updating autopilot destination to target to counter over-shooting
	---@param struct DronePortData
	["landing"] = function(struct)
		struct.drone.autopilot_destination = struct.base.position
		if game.tick > struct.state.delay then
			struct.state.status = "loading"
		end
	end,

	-- waiting for drone to arrive back home
	["emergency-recall"] = function() end,

	-- register arrival into home queue
	---@param struct DronePortData
	["emergency-arrival"] = function(struct)
		table.insert(struct.guests, struct.drone)
		struct.state.status = "waiting-to-emergency-arrive"
	end,

	-- wait until the drone is first in line
	---@param struct DronePortData
	["waiting-to-emergency-arrive"] = function(struct)
		local mypos = getDronePositionInQueue(struct.guests, struct.drone)
		if mypos > 1 then
			struct.drone.autopilot_destination = math2d.position.add(
				struct.base.position,
				math2d.position.rotate_vector({0,-8}, (mypos-1)/#struct.guests * 360)
			)
		else
			struct.drone.autopilot_destination = struct.base.position
			struct.state = {
				status = "emergency-landing",
				delay = game.tick + 25 * 60
			}
		end
	end,

	-- keep updating autopilot destination to target to counter over-shooting
	---@param struct DronePortData
	["emergency-landing"] = function(struct)
		struct.drone.autopilot_destination = struct.base.position
		if game.tick > struct.state.delay then
			-- skip loading phase so as not to contaminate Imports box
			struct.state.status = "waiting-for-destination"
		end
	end,

	__index = function(k)
		error("Unknown drone status "..k)
	end
}

---@param event on_tick
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
		checkIfDroneRanOutOfFuel(struct)
		drone_control_functions[struct.state.status](struct)
		updateStatusGui(struct)
	end
end

---@param event on_spider_command_completed
local function onSpiderDone(event)
	local spider = event.vehicle
	if spider.name == vehicle then
		local data = getStructFromDrone(spider)
		if data.state.status == "outbound" then
			data.state.status = "reached-destination"
		elseif data.state.status == "inbound" then
			data.state.status = "reached-home"
		elseif data.state.status == "emergency-recall" then
			data.state.status = "emergency-arrival"
		end
		removeSpeedSticker(data)
	end
end

---@param event on_player_configured_spider_remote
local function onSetupSpiderRemote(event)
	local player = game.players[event.player_index]
	local spider = event.vehicle
	if spider.name == vehicle then
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
		-- if the player is holding valid fuel for drones, try putting them in the fuel box
		if game.entity_prototypes[vehicle].burner_prototype.fuel_categories[player.cursor_stack.prototype.fuel_category] then
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

return bev.applyBuildEvents{
	on_init = function()
		global.drones = global.drones or script_data
		global.debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		script_data = global.drones or script_data
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
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
