local gui = {
	mode = require(modpath.."scripts.gui.station-mode"),
	tabs = require(modpath.."scripts.gui.truck-station-tabs")
}
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

---@class TruckStationData
---@field base LuaEntity ElectricEnergyInterface
---@field fuel LuaEntity Container
---@field cargo LuaEntity Container
---@field mode StationMode

---@alias TruckStationBucket table<uint, TruckStationData>

---@class global.trucks
---@field stations TruckStationBucket[]
local script_data = {
	stations = {}
}
for i=0,30-1 do script_data.stations[i] = {} end

---@param floor LuaEntity
local function getStruct(floor)
	return script_data.stations[floor.unit_number%30][floor.unit_number]
end
local function getBucket(tick)
	return script_data.stations[tick%30]
end
---@param floor LuaEntity
local function clearStruct(floor)
	script_data.stations[floor.unit_number%30][floor.unit_number] = nil
end

---@param entity LuaEntity
local function onBuilt(entity)
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
	io.addConnection(entity, {-1,3.5}, "input", store)
	io.addConnection(entity, {0,3.5}, "input", store)
	io.addConnection(entity, {2,3.5}, "output", store, defines.direction.south)
	io.addConnection(entity, {3,3.5}, "output", store, defines.direction.south)
	script_data.stations[entity.unit_number%30][entity.unit_number] = {
		base = entity,
		fuel = fuel,
		cargo = store,
		mode = "input"
	}
end

---@param entity LuaEntity
local function onRemoved(entity)
	clearStruct(entity)
end

---@param event on_player_rotated_entity
local function onRotated(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name ~= base then return end
	local data = getStruct(entity)
	data.mode = data.mode == "input" and "output" or "input"
	entity.direction = event.previous_direction
	player.create_local_flying_text{
		text = {"message.station-mode-toggle-"..data.mode},
		create_at_cursor = true
	}
	if player.opened == data.cargo then
		gui.mode.open_gui(player, data.base, data.cargo, data.mode)
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		-- opening the base instead opens the storage
		local data = getStruct(entity)
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
	if entity.name ~= storage and entity.name ~= fuelbox then return end

	local floor = entity.surface.find_entity(base, entity.position)
	local data = getStruct(floor)
	if entity.name == storage then
		gui.mode.open_gui(player, floor, entity, data.mode)
	end

	-- create fake tabs for switching to the fuel crate
	gui.tabs.open_gui(player, data.fuel, data.cargo)
end

---@param player LuaPlayer
---@param station LuaEntity
---@param mode StationMode
gui.mode.callbacks.toggle_truck = function(player, station, mode)
	local data = getStruct(station)
	if not data then return end
	data.mode = mode
end

---@param event on_tick
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
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
		-- check if a Truck can burn the given item
		if game.entity_prototypes["truck"].burner_prototype.fuel_categories[player.cursor_stack.prototype.fuel_category] then
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
	on_build = {
		callback = onBuilt,
		filter = {name=base}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name=base}
	},
	events = {
		[defines.events.on_player_rotated_entity] = onRotated,
		[defines.events.on_gui_opened] = onGuiOpened,

		[defines.events.on_tick] = onTick,

		["fast-entity-transfer-hook"] = function(event) onFastTransfer(event, false) end,
		["fast-entity-split-hook"] = function(event) onFastTransfer(event, true) end
	}
}
