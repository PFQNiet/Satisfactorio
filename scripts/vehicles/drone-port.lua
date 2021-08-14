---@class DroneStatus
---@field status string
---@field delay uint Tick number to wait until

---@class DroneTravelStats
---@field distance number
---@field time number
---@field batteries number
---@field throughput number

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

---@class DronePortStatus
---@field sprite SpritePath
---@field caption LocalisedString

---@alias DronePortBucket DronePortData[]

local gui = {
	port = require(modpath.."scripts.gui.drone-port"),
	tabs = require(modpath.."scripts.gui.drone-port-tabs")
}
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
---@param drone LuaEntity
local function getStructFromDrone(drone)
	return script_data.drones[drone.unit_number]
end
---@param floor LuaEntity
local function clearStruct(floor)
	script_data.ports[floor.unit_number%buckets][floor.unit_number] = nil
end
---@param drone LuaEntity
local function clearStructFromDrone(drone)
	script_data.drones[drone.unit_number] = nil
end

---@param data DronePortData
---@return DronePortData|nil
local function getPendingDestination(data)
	if data.queued_target and data.queued_target.valid then
		if data.queued_target == data.base then return nil end
		return getStruct(data.queued_target)
	end
	if data.target and data.target.valid then
		if data.target == data.base then return nil end
		return getStruct(data.target)
	end
	return nil
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
		batteries = batteries,
		throughput = 9 / (total_time/60)
	}
end

---@param data DronePortData
---@return DronePortStatus
local function getPortStatus(data)
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
	return {
		sprite = "utility/"..statuscolour,
		caption = {"gui.drone-status-"..status, delay}
	}
end

---@param entity LuaEntity
---@param reason LocalisedString
local function rejectBuild(entity, reason)
	local player = entity.last_user
	refundEntity(player, entity)
	if player then
		if not debounce_error[player.force.index] or debounce_error[player.force.index] < game.tick then
			player.create_local_flying_text{
				text = reason,
				create_at_cursor = true
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
			debounce_error[player.force.index] = game.tick + 60
		end
	end
end

---@param entity LuaEntity
local function onBuilt(entity)
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
			guests = {}
		}
	end
	if entity.name == vehicle then
		-- ensure there is a drone port here
		local port = entity.surface.find_entity(base, entity.position)
		if not port then
			return rejectBuild(entity, {"message.drone-must-be-built-on-port"})
		end
		local data = getStruct(port)
		if data.drone then
			return rejectBuild(entity, {"message.drone-port-has-another-drone"})
		end
		if #data.guests > 0 then
			return rejectBuild(entity, {"message.drone-port-is-busy"})
		end
		link.register(port, entity)
		entity.teleport(port.position)
		data.drone = entity
		entity.entity_label = data.name
		table.insert(data.guests, entity)
		data.state.status = "loading"
		registerDrone(data)

		gui.port.update.status(data, getPortStatus(data))
		gui.port.update.minimap(data)
	end
end

---@param entity LuaEntity
local function onRemoved(entity)
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

			gui.port.update.status(data, getPortStatus(data))
			gui.port.update.minimap(data)
		end
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.valid then
		if event.entity.name == base then
			local data = getStruct(event.entity)
			local destination = getPendingDestination(data)
			gui.port.open_gui(player, data, getPortStatus(data), destination, destination and calculateTravelStats(data.base, destination.base))
		end

		if event.entity.name == storage or event.entity.name == fuelbox then
			local floor = event.entity.surface.find_entity(base, event.entity.position)
			local data = getStruct(floor)
			gui.tabs.open_gui(player, data.stop, data.fuel, data.export, data.import)
		end

		if event.entity.name == stop then
			local floor = event.entity.surface.find_entity(base, event.entity.position)
			local data = getStruct(floor)
			local destination = getPendingDestination(data)
			gui.port.open_gui(player, data, getPortStatus(data), destination, destination and calculateTravelStats(data.base, destination.base))
		end
	end
end

-- if the player clicks on a station but can't reach it normally, open the stop anyway
local function onInteract(event)
	local player = game.players[event.player_index]
	local entity = player.selected
	if not (entity and entity.valid) then return end
	if entity.name ~= base then return end
	if player.can_reach_entity(entity) then return end
	local struct = getStruct(entity)
	player.opened = struct.stop
end

---@param player LuaPlayer
---@param port DronePortData
---@param name string
gui.port.callbacks.rename = function(player, port, name)
	port.name = name
	port.stop.backer_name = "[img=entity.drone-port] "..name
	if port.drone then port.drone.entity_label = name end
	gui.port.update.name(port)
end

---@param player LuaPlayer
---@param opened DronePortData
---@param query string
---@return DronePortData[]
gui.port.callbacks.search = function(player, opened, query)
	if query == "" then return {} end
	query = query:lower()
	local matches = {}
	for bucket in pairs(script_data.ports) do
		for _,struct in pairs(getBucket(bucket)) do
			if struct ~= opened and struct.name:lower():find(query, 1, true) then
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
	return matches
end

---@param player LuaPlayer
---@param port DronePortData
gui.port.callbacks.map_destination = function(player, port)
	local target = getPendingDestination(port)
	if target then
		player.open_map(target.base.position)
	end
end

---@param player LuaPlayer
---@param port DronePortData
gui.port.callbacks.map_drone = function(player, port)
	local target = port.drone or port.base
	player.open_map(target.position)
end

---@param player LuaPlayer
---@param port DronePortData
---@param destination_id uint
gui.port.callbacks.set_destination = function(player, port, destination_id)
	local target = getStructById(destination_id)
	if target and target ~= port then
		port.queued_target = target.base
		gui.port.update.destination(port, target)
		gui.port.update.statistics(port, calculateTravelStats(port.base, target.base))
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
		gui.port.update.status(struct, getPortStatus(struct))
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
	on_build = {
		callback = onBuilt,
		filter = {name={base, vehicle}}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name={base, vehicle}}
	},
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,

		[defines.events.on_player_configured_spider_remote] = onSetupSpiderRemote,
		[defines.events.on_spider_command_completed] = onSpiderDone,
		[defines.events.on_tick] = onTick,

		["interact"] = onInteract,
		["fast-entity-transfer-hook"] = function(event) onFastTransfer(event, false) end,
		["fast-entity-split-hook"] = function(event) onFastTransfer(event, true) end
	}
}
