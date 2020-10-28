local math2d = require("math2d")
local mod_gui = require("mod-gui")

-- uses global['cars'] to store all data
local function getCar(car)
	if not global['cars'] then global['cars'] = {} end
	if not global['cars'][car.unit_number] then
		global['cars'][car.unit_number] = {
			car = car,
			waypoints = {}, -- points defined by the player, (position, wait)
			waypoint_index = 1, -- which waypoint we're going to next
			wait_until = 0,
			autopilot = false,
			rendering = {}
		}
	end
	return global['cars'][car.unit_number]
end

local function turn(myvector, targetvector)
	myvector = math2d.position.ensure_xy(myvector)
	targetvector = math2d.position.ensure_xy(targetvector)
	local dir = math.atan2(myvector.x*targetvector.y - myvector.y*targetvector.x, myvector.x*targetvector.x + myvector.y*targetvector.y)
	-- >0 = anticlockwise
	-- <0 = clockwise
	if dir > 0.035 then return defines.riding.direction.right end
	if dir < -0.035 then return defines.riding.direction.left end
	return defines.riding.direction.straight
end
local function speed(myspeed, mypos, targetpos)
	-- if we're getting close to the target, slow down
	local wait = targetpos.wait
	mypos = math2d.position.ensure_xy(mypos)
	targetpos = math2d.position.ensure_xy(targetpos)
	local dx = mypos.x-targetpos.x
	local dy = mypos.y-targetpos.y
	local dist = math.sqrt(dx*dx+dy*dy)
	if dist < 2 and myspeed == 0 then return defines.riding.acceleration.nothing end -- this will register that the waypoint is reached and continue from there
	local ticks_to_target = dist/myspeed
	if ticks_to_target < 90 then return defines.riding.acceleration.braking end
	return defines.riding.acceleration.accelerating
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
local function refreshGui(car, menu)
	local index = menu and menu.selected_index
	for _,point in pairs(car.rendering) do
		rendering.destroy(point)
	end
	car.rendering = {}
	local driver = car.car.get_driver()
	if menu then menu.clear_items() end
	local prev
	for i,waypoint in pairs(car.waypoints) do
		if menu then
			menu.add_item({"gui.self-driving-waypoint",car.waypoint_index == i and {"gui.self-driving-waypoint-current"} or "",waypoint.x,waypoint.y,waypoint.wait})
		end
		if i > 1 then
			table.insert(car.rendering, rendering.draw_line{
				color = {1,1,0},
				width = 3,
				gap_length = 1,
				dash_length = 1,
				from = {prev.x,prev.y},
				to = {waypoint.x,waypoint.y},
				surface = car.car.surface,
				players = driver and {driver.is_player and driver or driver.player} or {},
				visible = driver and true or false
			})
		end
		prev = waypoint
	end
	if #car.waypoints > 1 then
		table.insert(car.rendering, rendering.draw_line{
			color = {1,1,0},
			width = 3,
			gap_length = 1,
			dash_length = 1,
			from = {car.waypoints[#car.waypoints].x,car.waypoints[#car.waypoints].y},
			to = {car.waypoints[1].x,car.waypoints[1].y},
			surface = car.car.surface,
			players = driver and {driver.is_player and driver or driver.player} or {},
			visible = driver and true or false
	})
	end
	if menu then
		menu.add_item({"gui.self-driving-waypoint-new"})
		menu.selected_index = index
	end
end

local function onTick(event)
	if not global['cars'] then return end
	local modulo = event.tick%30
	for i,car in pairs(global['cars']) do
		if not (car.car and car.car.valid) then
			table.remove(global['cars'],i)
		elseif car.autopilot and car.wait_until < event.tick and #car.waypoints > 1 and (i%30 == modulo or car.car.speed < 15) then
			-- slow cars should update more often - if we have speed then chances are we're happily on our way
			if car.waypoint_index > #car.waypoints then
				-- list was edited and no longer valid
				car.waypoint_index = findClosestWaypoint(car)
			end
			local mydir = {math.cos(math.pi*2*(0.25-car.car.orientation)), -math.sin(math.pi*2*(0.25-car.car.orientation))}
			local todir = {car.waypoints[car.waypoint_index].x-car.car.position.x, car.waypoints[car.waypoint_index].y-car.car.position.y}
			local steer = turn(mydir, todir)
			local accel = speed(car.car.speed, car.car.position, car.waypoints[car.waypoint_index])
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
					refreshGui(car, (driver.is_player and driver or driver.player).gui.left['self-driving']['self-driving-waypoints'])
				end
			end
		end
	end
end

local function isSelfDrivingCar(entity)
	return entity.name == "truck" or
		entity.name == "tractor" or
		entity.name == "explorer"
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
				style = mod_gui.frame_style
			}
			frame.style.horizontally_stretchable = false
			frame.style.use_header_filler = false

			frame.add{
				type = "switch",
				name = "self-driving-mode-toggle",
				switch_state = car.autopilot and "right" or "left",
				left_label_caption = {"gui.self-driving-mode-manual"},
				right_label_caption = {"gui.self-driving-mode-auto"}
			}

			local menu = frame.add{
				type = "list-box",
				name = "self-driving-waypoints"
			}
			menu.style.top_margin = 4
			menu.style.bottom_margin = 4
			menu.style.horizontally_stretchable = true
			menu.style.minimal_height = 200
			menu.style.maximal_height = 200

			refreshGui(car, menu)
			menu.selected_index = #menu.items

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
				text = 0,
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
				sprite = "utility.add"
			}
			local delbtn = flow.add{
				type = "sprite-button",
				name = "self-driving-delete",
				style = "tool_button_red",
				tooltip = {"gui.self-driving-waypoint-delete"},
				sprite = "utility.trash"
			}
			delbtn.enabled = false
		else
			-- delete the gui
			if gui['self-driving'] then
				gui['self-driving'].destroy()
			end
			refreshGui(car) -- basically just hide the rendering from this player
		end
	end
end
local function onGuiClick(event)
	local player = game.players[event.player_index]
	if event.element.valid and event.element.name == "self-driving-add" then
		-- all of this must exist for the GUI button to exist
		local gui = player.gui.left['self-driving']
		local car = getCar(player.vehicle)
		local list = gui['self-driving-waypoints']
		local index = list.selected_index
		local time = tonumber(gui['self-driving-edit']['self-driving-time'].text)
		if index > #car.waypoints then
			-- new waypoint
			local waypoint = {
				x = math.floor(car.car.position.x),
				y = math.floor(car.car.position.y),
				wait = time
			}
			table.insert(car.waypoints, waypoint)
			list.add_item({"gui.self-driving-waypoint","",waypoint.x,waypoint.y,waypoint.wait}, index)
			refreshGui(car, list)
		else
			-- update waypoint time
			local waypoint = car.waypoints[index]
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
			table.remove(car.waypoints, index)
			list.remove_item(index)
		end
	end
end
local function onGuiSelection(event)
	local player = game.players[event.player_index]
	if event.element.valid and event.element.name == "self-driving-waypoints" then
		local index = event.element.selected_index
		local edit = player.gui.left['self-driving']['self-driving-edit']
		local car = getCar(player.vehicle)
		if index < #event.element.items then
			edit['self-driving-add'].tooltip = {"gui.self-driving-waypoint-edit"}
			edit['self-driving-delete'].enabled = not car.autopilot
		else
			edit['self-driving-add'].tooltip = {"gui.self-driving-waypoint-add"}
			edit['self-driving-delete'].enabled = false
		end
	end
end
local function onGuiSwitch(event)
	local player = game.players[event.player_index]
	if event.element.valid and event.element.name == "self-driving-mode-toggle" then
		local car = getCar(player.vehicle)
		car.autopilot = event.element.switch_state == "right"
		local edit = player.gui.left['self-driving']['self-driving-edit']
		local waypoints = player.gui.left['self-driving']['self-driving-waypoints']
		edit['self-driving-add'].enabled = not car.autopilot
		edit['self-driving-delete'].enabled = not car.autopilot and waypoints.selected_index ~= #waypoints.items
		if not car.autopilot then
			car.car.riding_state = {
				acceleration = defines.riding.acceleration.nothing,
				direction = defines.riding.direction.straight
			}
		end
		car.waypoint_index = findClosestWaypoint(car)
		refreshGui(car, waypoints)
	end
end


return {
	events = {
		[defines.events.on_tick] = onTick,
		[defines.events.on_player_driving_changed_state] = onDriving,

		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_selection_state_changed] = onGuiSelection,
		[defines.events.on_gui_switch_state_changed] = onGuiSwitch
	}
}
