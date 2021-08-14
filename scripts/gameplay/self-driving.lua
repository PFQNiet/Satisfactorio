local gui = require(modpath.."scripts.gui.self-driving")
local bev = require(modpath.."scripts.lualib.build-events")
local math2d = require("math2d")

---@class SelfDrivingWaypoint:Position
---@field wait number Seconds to wait at this position
---@field name string Player-given name to this stop

---@class SelfDrivingCarData
---@field car LuaEntity
---@field waypoints SelfDrivingWaypoint[]
---@field waypoint_index uint Index of the waypoint that's being travelled to next
---@field wait_until uint Tick to depart from current waypoint
---@field recording boolean
---@field autopilot boolean
---@field rendering uint64[] Graphics IDs

---@alias global.cars table<uint, SelfDrivingCarData> Indexed by car unit number
---@type global.cars
local script_data = {}

---@param car LuaEntity Car
---@return SelfDrivingCarData
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

---@param entity LuaEntity Car
local function deleteCar(entity)
	local car = getCar(entity)
	for _,line in pairs(car.rendering) do
		rendering.destroy(line)
	end
	script_data[entity.unit_number] = nil
end

---@param myvector Vector
---@param targetvector Vector
---@return defines.riding.direction
---@return number Angle +anticlockwise -clockwise
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

---@param myspeed number
---@param mypos Position
---@param targetpos SelfDrivingWaypoint
---@param steer defines.riding.direction
---@param delta number Angle in radians
---@return defines.riding.acceleration
---@return number Distance
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

---@param car SelfDrivingCarData
---@return number Index
local function findClosestWaypoint(car)
	local closest = {0,math.huge}
	local carpos = car.car.position
	for i,waypoint in pairs(car.waypoints) do
		local dx = waypoint.x-carpos.x
		local dy = waypoint.y-carpos.y
		local dist2 = dx*dx+dy*dy
		if dist2 < closest[2] then
			closest = {i,dist2}
		end
	end
	return closest[1]
end

---@param car SelfDrivingCarData
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
		if waypoint.wait > 0 then
			table.insert(car.rendering, rendering.draw_text{
				text = {"time-symbol-seconds-short", waypoint.wait},
				color = {1,1,1},
				target = {waypoint.x, waypoint.y},
				surface = car.car.surface,
				alignment = "center",
				vertical_alignment = "middle",
				only_in_alt_mode = not car.recording
			})
		end
		prev = waypoint
	end
	if car.recording then
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

---@param event on_tick
local function onTick(event)
	for i,car in pairs(script_data) do
		if not (car.car and car.car.valid) then
			script_data[i] = nil
		else
			local carpos = car.car.position
			if car.recording then
				-- if driving straight, don't bother recording waypoints
				if event.tick%5 == 0 and car.car.riding_state.direction ~= defines.riding.direction.straight then
					-- get proximity with previous waypoint and, if it's too close, don't record it either
					if #car.waypoints == 0 or math2d.position.distance(car.waypoints[#car.waypoints], carpos) > 3 then
						table.insert(car.waypoints, {
							x = carpos.x,
							y = carpos.y,
							wait = 0
						})
						refreshPathRender(car)
					end
				end
			elseif car.autopilot then
				if car.crash_tick then
					car.car.riding_state = {
						acceleration = defines.riding.acceleration.reversing,
						direction = defines.riding.direction.straight
					}
					if math.random(60) < event.tick - car.crash_tick then
						car.crash_tick = nil
					end
				elseif car.wait_until < event.tick and #car.waypoints > 1 and (not car.sleep_until or car.sleep_until < event.tick) then
					if car.waypoint_index > #car.waypoints then
						-- list was edited and no longer valid
						car.waypoint_index = findClosestWaypoint(car)
					end
					local waypoint = car.waypoints[car.waypoint_index]
					local cardir = math.pi*2*(0.25-car.car.orientation)
					local carspeed = car.car.speed
					local mydir = {math.cos(cardir), -math.sin(cardir)}
					local todir = {waypoint.x-carpos.x, waypoint.y-carpos.y}
					local steer, delta = turn(mydir, todir)
					local accel, distance = speed(carspeed, carpos, waypoint, steer, delta)
					car.car.riding_state = {
						acceleration = accel,
						direction = steer
					}
					if accel == defines.riding.acceleration.nothing then
						-- arrived at waypoint, go to next
						car.wait_until = event.tick + waypoint.wait*60
						car.waypoint_index = car.waypoint_index % #car.waypoints + 1
						local driver = car.car.get_driver()
						if driver then
							gui.update_gui(driver.is_player() and driver or driver.player)
						end
						local passenger = car.car.get_passenger()
						if passenger then
							gui.update_gui(passenger.is_player() and passenger or passenger.player)
						end
					elseif not car.fuel_check or car.fuel_check < event.tick then
						local fuel = car.car.burner
						if not fuel.currently_burning and not fuel.inventory[1].valid_for_read then
							for _,player in pairs(car.car.force.players) do
								player.add_alert(car.car, defines.alert_type.train_out_of_fuel)
							end
						end
						car.fuel_check = event.tick + 300 -- alerts last 5 seconds so only bother checking every 5 seconds
					end
					if accel == defines.riding.acceleration.accelerating and steer == defines.riding.direction.straight and carspeed > 0.05 then
						-- driving straight, sleep based on current ticks to near destination
						car.sleep_until = event.tick + math.min(distance/carspeed/1.2 - 90, 60) -- wake up 90 ticks before destination, based on current speed plus a bit
					end
				end
			end
		end
	end
end

---@param entity LuaEntity
local function isSelfDrivingCar(entity)
	if not (entity and entity.valid) then return false end
	return entity.name == "truck" or
		entity.name == "tractor" or
		entity.name == "explorer"
end

-- On crashing into something, record that into the struct so it tries to reverse
---@param event on_entity_damaged
local function onDamaged(event)
	local entity = event.entity
	if isSelfDrivingCar(entity) and event.damage_type.name == "impact" then
		local car = getCar(entity)
		if car and car.autopilot and not car.crash_tick then
			car.crash_tick = event.tick
		end
	end
end

---@param event on_player_driving_changed_state
local function onDriving(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity and entity.valid and isSelfDrivingCar(entity) then
		local car = getCar(entity)
		if not player.driving and car.recording then
			car.waypoints = {}
			car.recording = false
			player.print{"message.self-driving-recording-aborted"}
		end
		gui.update_gui(player)
	end
end

---@param event on_gui_opened
local function onGuiOpen(event)
	local player = game.players[event.player_index]
	if isSelfDrivingCar(player.vehicle) and player.opened_self then
		player.opened = player.vehicle
	end
	if player.opened_gui_type == defines.gui_type.entity and isSelfDrivingCar(player.opened) then
		gui.open_gui(player, getCar(player.opened))
	end
end

---@param player LuaPlayer
---@param car SelfDrivingCarData
gui.callbacks.toggle_recording = function(player, car)
	if not car.recording then
		if car.autopilot then
			player.print{"message.self-driving-recording-disable-autopilot"}
		else
			player.print{"message.self-driving-recording-started"}
			car.recording = true
			local carpos = car.car.position
			car.waypoints = {
				{
					x = carpos.x,
					y = carpos.y,
					wait = 0
				}
			}
			refreshPathRender(car)
		end
	else
		if math2d.position.distance(car.waypoints[1], car.car.position) > 2 then
			player.print{"message.self-driving-recording-must-close"}
		else
			player.print{"message.self-driving-recording-finished"}
			car.recording = false
		end
	end
end

---@param player LuaPlayer
---@param car SelfDrivingCarData
---@param on boolean
gui.callbacks.toggle_autopilot = function(player, car, on)
	car.autopilot = on
	if not on then
		car.car.riding_state = {
			acceleration = defines.riding.acceleration.nothing,
			direction = defines.riding.direction.straight
		}
	else
		car.waypoint_index = findClosestWaypoint(car)
	end
	refreshPathRender(car)
end

---@param player LuaPlayer
---@param car SelfDrivingCarData
---@param name string
---@param wait number
gui.callbacks.add_waypoint = function(player, car, name, wait)
	if not car.recording then return end
	if wait <= 0 then return end

	local carpos = car.car.position
	table.insert(car.waypoints, {
		x = carpos.x,
		y = carpos.y,
		wait = wait,
		name = name
	})
	refreshPathRender(car)
end

return bev.applyBuildEvents{
	on_init = function()
		global.cars = global.cars or script_data
	end,
	on_load = function()
		script_data = global.cars or script_data
	end,
	on_destroy = {
		callback = deleteCar,
		filter = {name={"truck", "tractor", "explorer"}}
	},
	events = {
		[defines.events.on_tick] = onTick,
		[defines.events.on_player_driving_changed_state] = onDriving,

		[defines.events.on_gui_opened] = onGuiOpen,

		[defines.events.on_entity_damaged] = onDamaged
	}
}
