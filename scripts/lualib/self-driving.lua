local math2d = require("math2d")
local table_size = table_size
local script_data = {}

-- uses global.cars to store all data
local function getCar(car)
	if not script_data[car.unit_number] then
		script_data[car.unit_number] = {
			car = car,
			waypoints = {}, -- points defined by the player, (position, wait)
			waypoint_index = 1, -- which waypoint we're going to next
			wait_until = 0,
			recording = false,
			autopilot = false,
			rendering = {}
		}
	end
	return script_data[car.unit_number]
end
local function deleteCar(car)
	script_data[car.unit_number] = nil
end

local function turn(myvector, targetvector)
	myvector = math2d.position.ensure_xy(myvector)
	targetvector = math2d.position.ensure_xy(targetvector)
	local dir = math.atan2(myvector.x*targetvector.y - myvector.y*targetvector.x, myvector.x*targetvector.x + myvector.y*targetvector.y)
	-- >0 = anticlockwise
	-- <0 = clockwise
	if dir > 0.035 then return defines.riding.direction.right, dir end
	if dir < -0.035 then return defines.riding.direction.left, dir end
	return defines.riding.direction.straight, dir
end
local function speed(myspeed, mypos, targetpos, steer, delta)
	-- if we're getting close to the target, slow down
	local wait = targetpos.wait
	mypos = math2d.position.ensure_xy(mypos)
	targetpos = math2d.position.ensure_xy(targetpos)
	local dx = mypos.x-targetpos.x
	local dy = mypos.y-targetpos.y
	local dist = math.sqrt(dx*dx+dy*dy)
	local accel
	if dist < 2 and myspeed == 0 then
		-- register that the waypoint is reached and continue from there
		accel = defines.riding.acceleration.nothing
	elseif steer == defines.riding.direction.straight and wait == 0 then
		-- if car is driving straight and waypoint has no wait time, then there is no need to brake - just continue
		accel = dist < 3 and defines.riding.acceleration.nothing or defines.riding.acceleration.accelerating
	elseif math.abs(dist/myspeed) < 90 then -- ticks to target
		accel = defines.riding.acceleration.braking
	elseif delta < -1.6 or delta > 1.6 then
		accel = defines.riding.acceleration.reversing
	else
		accel = defines.riding.acceleration.accelerating
	end
	return accel, dist
end

local function findClosestWaypoint(car)
	local closest = {0,math.huge}
	for i,waypoint in pairs(car.waypoints) do
		local dx = waypoint.x-car.car.position.x
		local dy = waypoint.y-car.car.position.y
		local dist2 = dx*dx+dy*dy
		if dist2 < closest[2] then
			closest = {i,dist2}
		end
	end
	return closest[1]
end

local function refreshStopList(car, menu)
	local index = menu.selected_index
	menu.clear_items()
	for i,waypoint in pairs(car.waypoints) do
		if waypoint.wait > 0 then
			menu.add_item({"gui.self-driving-waypoint",
				(i%#car.waypoints)+1 == car.waypoint_index and {"gui.self-driving-waypoint-current"} or "",
				waypoint.x, waypoint.y,
				waypoint.wait
			})
		end
	end
	if car.recording then
		menu.add_item({"gui.self-driving-waypoint-new"})
	end
	if #menu.items > 0 then
		menu.selected_index = index > 0 and math.min(index,#menu.items) or #menu.items
	end
end
local function refreshPathRender(car)
	for _,line in pairs(car.rendering) do
		rendering.destroy(line)
	end
	car.rendering = {}
	local prev
	for i,waypoint in pairs(car.waypoints) do
		if i == 1 then
			if car.recording then
				table.insert(car.rendering, rendering.draw_circle{
					color = {1,1,0},
					radius = 2,
					width = 1,
					filled = false,
					target = {waypoint.x,waypoint.y},
					surface = car.car.surface,
					draw_on_ground = true
				})
			end
		else
			table.insert(car.rendering, rendering.draw_line{
				color = {1,1,0},
				width = 1,
				gap_length = 1,
				dash_length = 3,
				from = {prev.x,prev.y},
				to = {waypoint.x,waypoint.y},
				surface = car.car.surface,
				draw_on_ground = true,
				only_in_alt_mode = not car.recording
			})
		end
		prev = waypoint
	end
	if #car.waypoints > 0 and car.recording then
		table.insert(car.rendering, rendering.draw_line{
			color = {1,1,0},
			width = 1,
			gap_length = 1,
			dash_length = 3,
			from = {car.waypoints[#car.waypoints].x,car.waypoints[#car.waypoints].y},
			to = car.car,
			surface = car.car.surface,
			draw_on_ground = true,
			only_in_alt_mode = not car.recording
		})
	elseif #car.waypoints > 1 then
		table.insert(car.rendering, rendering.draw_line{
			color = {1,1,0},
			width = 1,
			gap_length = 1,
			dash_length = 3,
			from = {car.waypoints[#car.waypoints].x,car.waypoints[#car.waypoints].y},
			to = {car.waypoints[1].x,car.waypoints[1].y},
			surface = car.car.surface,
			draw_on_ground = true,
			only_in_alt_mode = not car.recording
		})
	end
end

local function onTick(event)
	for i,car in pairs(script_data) do
		if not (car.car and car.car.valid) then
			script_data[i] = nil
		elseif car.recording then
			-- if driving straight, don't bother recording waypoints
			if event.tick%5 == 0 and car.car.riding_state.direction ~= defines.riding.direction.straight then
				-- get proximity with previous waypoint and, if it's too close, don't record it either
				if #car.waypoints == 0 or math2d.position.distance(car.waypoints[#car.waypoints], car.car.position) > 3 then
					table.insert(car.waypoints, {
						x = car.car.position.x,
						y = car.car.position.y,
						wait = 0
					})
					refreshPathRender(car)
				end
			end
		elseif car.autopilot and car.crash_tick then
			car.car.riding_state = {
				acceleration = defines.riding.acceleration.reversing,
				direction = defines.riding.direction.straight
			}
			if math.random(60) < event.tick - car.crash_tick then
				car.crash_tick = nil
			end
		elseif car.autopilot and car.wait_until < event.tick and #car.waypoints > 1 and (not car.sleep_until or car.sleep_until < event.tick) then
			if car.waypoint_index > #car.waypoints then
				-- list was edited and no longer valid
				car.waypoint_index = findClosestWaypoint(car)
			end
			local mydir = {math.cos(math.pi*2*(0.25-car.car.orientation)), -math.sin(math.pi*2*(0.25-car.car.orientation))}
			local todir = {car.waypoints[car.waypoint_index].x-car.car.position.x, car.waypoints[car.waypoint_index].y-car.car.position.y}
			local steer, delta = turn(mydir, todir)
			local accel, distance = speed(car.car.speed, car.car.position, car.waypoints[car.waypoint_index], steer, delta)
			car.car.riding_state = {
				acceleration = accel,
				direction = steer
			}
			if accel == defines.riding.acceleration.nothing then
				-- arrived at waypoint, go to next
				car.wait_until = event.tick + car.waypoints[car.waypoint_index].wait*60
				car.waypoint_index = car.waypoint_index % #car.waypoints + 1
				local driver = car.car.get_driver()
				if driver then
					-- gui exists in this case
					refreshStopList(car, (driver.is_player() and driver or driver.player).gui.left['self-driving']['self-driving-waypoints'])
				end
			elseif not car.fuel_check or car.fuel_check < event.tick then
				local fuel = car.car.burner
				if not fuel.currently_burning and not fuel.inventory[1].valid_for_read then
					for _,player in pairs(car.car.force.players) do
						player.add_alert(car.car, defines.alert_type.train_out_of_fuel)
					end
				elseif car.car.riding_state.acceleration ~= defines.riding.acceleration.nothing and car.car.speed == 0 then
					if not car.crash_check or car.crash_check < 2 then
						car.crash_check = (car.crash_check or 0) + 1
					else
						-- car is trying to move but can't, despite having fuel, and has failed this check 3 times
						-- TODO update/remove this, as the new "reverse and try again" mechanic overrides this
						for _,player in pairs(car.car.force.players) do
							player.add_custom_alert(car.car, {type="virtual",name="signal-vehicle-crashed"}, {"gui-alert-tooltip.vehicle-crashed",{"entity-name."..car.car.name}}, true)
						end
					end
				else
					if car.crash_check then car.crash_check = 0 end
					for _,player in pairs(car.car.force.players) do
						player.remove_alert{entity=car.car, icon={type="virtual",name="signal-vehicle-crashed"}}
					end
				end
				car.fuel_check = event.tick + 300 -- alerts last 5 seconds so only bother checking every 5 seconds
			end
			if accel == defines.riding.acceleration.accelerating and steer == defines.riding.direction.straight and car.car.speed > 0.05 then
				-- driving straight, sleep based on current ticks to near destination
				car.sleep_until = event.tick + math.min(distance/car.car.speed/1.2 - 90, 60) -- wake up 90 ticks before destination, based on current speed plus a bit
			end
		end
	end
end

local function isSelfDrivingCar(entity)
	return entity.name == "truck" or
		entity.name == "tractor" or
		entity.name == "explorer"
end
local function onDamaged(event)
	local entity = event.entity
	if isSelfDrivingCar(entity) and event.damage_type.name == "impact" then
		local car = getCar(entity)
		if car and car.autopilot and not car.crash_tick then
			car.crash_tick = event.tick
		end
	end
end
local function onDriving(event)
	-- when a player enters/leaves a car
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity and entity.valid and isSelfDrivingCar(entity) then
		local gui = player.gui.left
		local car = getCar(entity)
		if player.driving and player.vehicle == entity then
			-- create the gui
			if gui['self-driving'] then
				gui['self-driving'].destroy()
			end
			local frame = gui.add{
				type = "frame",
				name = "self-driving",
				direction = "vertical",
				caption = {"gui.self-driving-title"},
				style = "inner_frame_in_outer_frame"
			}
			frame.style.horizontally_stretchable = false
			frame.style.use_header_filler = false

			local switch = frame.add{
				type = "switch",
				name = "self-driving-mode-toggle",
				switch_state = car.autopilot and "right" or "left",
				left_label_caption = {"gui.self-driving-mode-manual"},
				right_label_caption = {"gui.self-driving-mode-auto"}
			}
			switch.enabled = #car.waypoints > 0 and not car.recording
			local button = frame.add{
				type = "button",
				name = "self-driving-record",
				caption = {"gui.self-driving-record"}
			}
			button.style.horizontally_stretchable = true

			local menu = frame.add{
				type = "list-box",
				name = "self-driving-waypoints"
			}
			menu.style.horizontally_stretchable = true
			menu.style.height = 200

			refreshStopList(car, menu)

			local flow = frame.add{
				type = "flow",
				name = "self-driving-edit"
			}
			flow.style.vertical_align = "center"
			flow.add{
				type = "label",
				caption = {"gui.self-driving-waypoint-wait"}
			}
			local input = flow.add{
				type = "textfield",
				name = "self-driving-time",
				numeric = true,
				text = 25,
				allow_decimal = false,
				allow_negative = false
			}
			input.style.width = 50
			flow.add{
				type = "label",
				caption = {"gui.self-driving-waypoint-seconds"}
			}
			local addbtn = flow.add{
				type = "sprite-button",
				name = "self-driving-add",
				style = "tool_button_green",
				tooltip = {"gui.self-driving-waypoint-add"},
				sprite = "utility/reassign"
			}
			addbtn.enabled = false
			local delbtn = flow.add{
				type = "sprite-button",
				name = "self-driving-delete",
				style = "tool_button_red",
				tooltip = {"gui.self-driving-waypoint-delete"},
				sprite = "utility/trash"
			}
			delbtn.enabled = false
		else
			-- delete the gui
			if gui['self-driving'] then
				gui['self-driving'].destroy()
			end
			if car.recording then
				car.waypoints = {}
				car.recording = false
				player.print{"message.self-driving-recording-aborted"}
				refreshPathRender(car)
			end
		end
	end
end
local function onGuiClick(event)
	local player = game.players[event.player_index]
	if event.element.valid and event.element.name == "self-driving-record" then
		-- all of this must exist for the GUI button to exist
		local gui = player.gui.left['self-driving']
		if not player.vehicle then
			gui.destroy()
			return
		end
		local car = getCar(player.vehicle)
		if not car.recording then
			if car.autopilot then
				player.print{"message.self-driving-recording-disable-autopilot"}
			else
				player.print{"message.self-driving-recording-started"}
				car.recording = true
				car.waypoints = {}
				table.insert(car.waypoints, {
					x = car.car.position.x,
					y = car.car.position.y,
					wait = 0
				})
				refreshPathRender(car)
				refreshStopList(car, gui['self-driving-waypoints'])
				gui['self-driving-mode-toggle'].enabled = false
				gui['self-driving-record'].caption = {"gui.self-driving-stop"}
				gui['self-driving-edit']['self-driving-add'].enabled = true
			end
		else
			-- recording must have at least one waypoint, and car must be in the starting circle
			if #car.waypoints == 0 or math2d.position.distance(car.waypoints[1], car.car.position) > 2 then
				player.print{"message.self-driving-recording-must-close"}
			else
				player.print{"message.self-driving-recording-finished"}
				car.recording = false
				gui['self-driving-mode-toggle'].enabled = true
				gui['self-driving-record'].caption = {"gui.self-driving-record"}
				gui['self-driving-edit']['self-driving-add'].enabled = false
			end
		end
	end
	if event.element.valid and event.element.name == "self-driving-add" then
		-- all of this must exist for the GUI button to exist
		local gui = player.gui.left['self-driving']
		local car = getCar(player.vehicle)
		local list = gui['self-driving-waypoints']
		local index = list.selected_index
		local time = tonumber(gui['self-driving-edit']['self-driving-time'].text)
		if time == 0 then return end
		-- scan waypoint list for stops
		local stops = {}
		for _,waypoint in pairs(car.waypoints) do
			if waypoint.wait > 0 then
				table.insert(stops, waypoint)
			end
		end
		if index == 0 or index > #stops then
			if not car.recording then return end
			index = #stops + 1
			-- new waypoint
			local waypoint = {
				x = math.floor(car.car.position.x),
				y = math.floor(car.car.position.y),
				wait = time
			}
			table.insert(car.waypoints, waypoint)
			list.add_item({"gui.self-driving-waypoint","",waypoint.x,waypoint.y,waypoint.wait}, index)
			refreshPathRender(car)
		else
			-- update stop time (can be done even if car is currently on autopilot)
			local waypoint = stops[index]
			waypoint.wait = time
			list.set_item(index, {"gui.self-driving-waypoint","",waypoint.x,waypoint.y,waypoint.wait})
		end
	end
	if event.element.valid and event.element.name == "self-driving-delete" then
		-- all of this must exist for the GUI button to exist
		local gui = player.gui.left['self-driving']
		local car = getCar(player.vehicle)
		local list = gui['self-driving-waypoints']
		local index = list.selected_index
		if index > 0 and index <= #car.waypoints then
			list.remove_item(index)
			-- scan waypoint list for stops
			local stops = {}
			for i,waypoint in pairs(car.waypoints) do
				if waypoint.wait > 0 then
					index = index - 1
					if index == 0 then
						table.remove(car.waypoints, i)
						break
					end
				end
			end
			refreshPathRender(car)
		end
	end
end
local function onGuiSelection(event)
	local player = game.players[event.player_index]
	if event.element.valid and event.element.name == "self-driving-waypoints" then
		if not player.vehicle then
			return
		end
		local index = event.element.selected_index
		local edit = player.gui.left['self-driving']['self-driving-edit']
		local car = getCar(player.vehicle)
		if index <= #car.waypoints then
			edit['self-driving-add'].tooltip = {"gui.self-driving-waypoint-edit"}
			edit['self-driving-add'].sprite = "utility/upgrade_blueprint"
			edit['self-driving-add'].enabled = true
			edit['self-driving-delete'].enabled = not car.autopilot
		else
			edit['self-driving-add'].tooltip = {"gui.self-driving-waypoint-add"}
			edit['self-driving-add'].sprite = "utility/reassign"
			edit['self-driving-add'].enabled = car.recording
			edit['self-driving-delete'].enabled = false
		end
	end
end
local function onGuiSwitch(event)
	local player = game.players[event.player_index]
	if event.element.valid and event.element.name == "self-driving-mode-toggle" then
		if not player.vehicle then
			return
		end
		local car = getCar(player.vehicle)
		car.autopilot = event.element.switch_state == "right"
		local edit = player.gui.left['self-driving']['self-driving-edit']
		local waypoints = player.gui.left['self-driving']['self-driving-waypoints']
		edit['self-driving-add'].enabled = not car.autopilot and waypoints.selected_index <= #waypoints.items
		edit['self-driving-delete'].enabled = not car.autopilot and waypoints.selected_index <= #waypoints.items
		if not car.autopilot then
			car.car.riding_state = {
				acceleration = defines.riding.acceleration.nothing,
				direction = defines.riding.direction.straight
			}
		end
		car.waypoint_index = findClosestWaypoint(car)
		refreshPathRender(car)
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity and entity.valid and isSelfDrivingCar(entity) then
		local car = getCar(entity)
		for _,line in pairs(car.rendering) do
			rendering.destroy(line)
		end
		deleteCar(entity)
	end
end

local function onPlayerDied(event)
	local player = game.players[event.player_index]
	local gui = player.gui.left['self-driving']
	if gui then gui.destroy() end
end

return {
	on_init = function()
		global.cars = global.cars or script_data
	end,
	on_load = function()
		script_data = global.cars or script_data
	end,
	events = {
		[defines.events.on_tick] = onTick,
		[defines.events.on_player_driving_changed_state] = onDriving,
		
		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_selection_state_changed] = onGuiSelection,
		[defines.events.on_gui_switch_state_changed] = onGuiSwitch,

		[defines.events.on_entity_damaged] = onDamaged,
		[defines.events.on_player_died] = onPlayerDied
	}
}
