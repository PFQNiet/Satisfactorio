-- uses global.train.stations to list all train stations {station, stop} - in buckets modulo 45
-- uses global.train.platforms to list freight platforms {entity, mode}
-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors
-- uses global.train.accounted to track train IDs that have already been counted by a station in the last cycle
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local fastTransfer = require(modpath.."scripts.organisation.containers").fastTransfer
local refundEntity = require(modpath.."scripts.lualib.building-management").refundEntity
local link = require(modpath.."scripts.lualib.linked-entity")
local math2d = require("math2d")

local station = "train-station"
local freight = "freight-platform"
local fluid = "fluid-freight-platform"
local empty = "empty-platform"
local trainstop = "train-stop"
local stop_pos = {2,-2.5}
local storage_pos = {3.5,0}
local tank_pos = {4.5,0}
local walkable = "platform-walkable"
local collision = "platform-collision"

---@class TrainStationData
---@field id uint
---@field type "station"
---@field station LuaEntity
---@field stop LuaEntity
---@field next TrainPlatformData|nil

---@class TrainPlatformData
---@field id uint
---@field type "platform"
---@field platform LuaEntity
---@field storage LuaEntity|nil
---@field mode "input"|"output"
---@field next TrainPlatformData|nil
---@field previous TrainPlatformData|TrainStationData

---@class global.trains
---@field stations table<uint, table<uint, TrainStationData>> Map of station unit_number to station data, bucketed modulo 45
---@field platforms table<uint, TrainPlatformData> Map of platform unit_number to platfrom data
---@field accounted table<uint, boolean> List of trains that have been accounted for this cycle
local script_data = {
	stations = {},
	platforms = {},
	accounted = {}
}
for i=0,45-1 do script_data.stations[i] = {} end

---@param struct TrainStationData
local function registerStation(struct)
	script_data.stations[struct.id%45][struct.id] = struct
end
local function unregisterStation(id)
	script_data.stations[id%45][id] = nil
end
local function getStationBucket(tick)
	return script_data.stations[tick%45]
end
local function getStation(entity)
	return script_data.stations[entity.unit_number%45][entity.unit_number]
end

---@param struct TrainPlatformData
local function registerPlatform(struct)
	script_data.platforms[struct.id] = struct
end
local function unregisterPlatform(id)
	script_data.platforms[id] = nil
end
local function getPlatform(entity)
	return script_data.platforms[entity.unit_number]
end
local function getPlatformByStorage(entity)
	local floor = entity.surface.find_entities_filtered{
		name = {freight, fluid},
		position = entity.position,
		force = entity.force
	}[1]
	if floor then
		return getPlatform(floor)
	end
end

local function getPlatformOrStation(entity)
	if entity.name == station then
		return getStation(entity)
	else
		return getPlatform(entity)
	end
end
local function unregisterPlatformOrStation(entity)
	if entity.name == station then
		unregisterStation(entity.unit_number)
	else
		unregisterPlatform(entity.unit_number)
	end
end

local debounce_error = {}
--- refund the entity and trigger an error message flying text (but only if event.tick is not too recent from the last one)
---@param entity LuaEntity
---@param reason LocalisedString
---@param event EventData
local function denyConstruction(entity, reason, event)
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

--- ensure that the entity is at the expected position
---@param entity LuaEntity
---@param position Position
---@return boolean
local function assertPosition(entity, position)
	if not (entity and entity.valid) then return false end
	if math.abs((entity.position.x or entity.position[1]) - (position.x or position[1])) > 0.01 then return false end
	if math.abs((entity.position.y or entity.position[2]) - (position.y or position[2])) > 0.01 then return false end
	return true
end

---@param event on_built_entity|on_robot_built_entity|script_raised_built|script_raised_revive
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == station or entity.name == freight or entity.name == fluid or entity.name == empty then
		-- check if it collides with something
		local colliders = entity.surface.find_entities_filtered{
			area = entity.bounding_box,
			collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"}
		}
		for _,collider in pairs(colliders) do
			if collider ~= entity and collider.name ~= "straight-rail" then
				return denyConstruction(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
			end
			if collider.name == "straight-rail" then
				-- only allowed on the central line, and even then only in the same direction
				if collider.direction%4 ~= entity.direction%4 then -- rails are limited to north/east
					return denyConstruction(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
				end
				if entity.direction == defines.direction.north or entity.direction == defines.direction.south then
					if collider.position.x ~= entity.position.x then
						return denyConstruction(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
					end
				else
					if collider.position.y ~= entity.position.y then
						return denyConstruction(entity, {"cant-build-reason.entity-in-the-way",collider.localised_name or {"entity-name."..collider.name}}, event)
					end
				end
			end
		end

		if entity.name == station then
			-- station must be on rail grid
			-- entity is 7x14 and station is placed at {2,-2.5} relative to the entity
			local stationpos = math2d.position.add(entity.position, math2d.position.rotate_vector(stop_pos, entity.direction*45))
			stationpos.x = math.floor(stationpos.x+0.01) -- epsilon for checking if entity is on the grid
			stationpos.y = math.floor(stationpos.y+0.01)
			-- stationpos should now be on the 2x2 grid, that is the grid where centre points are ODD
			if stationpos.x%2 ~= 1 or stationpos.y%2 ~= 1 then
				return denyConstruction(entity, {"message.entity-must-be-placed-on-rail-grid",{"entity-name."..entity.name}}, event)
			end

			-- look for an existing platform to bind to
			local behind = math2d.position.add(entity.position, math2d.position.rotate_vector({0,7}, entity.direction*45))
			local platform = entity.surface.find_entities_filtered{
				name = {freight, fluid, empty},
				position = behind,
				force = entity.force
			}[1]
			-- prevent double-ended stations by ensuring the platform doesn't link backwards to another station
			if platform and assertPosition(platform, behind) then
				local lookup = getPlatform(platform)
				while lookup and lookup.type == "platform" do
					lookup = lookup.previous
				end
				if lookup then
					return denyConstruction(entity, {"message.no-double-ended-stations"}, event)
				end
			else
				platform = nil
			end

			local stop = entity.surface.create_entity{
				name = trainstop,
				position = stationpos,
				direction = entity.direction,
				force = entity.force,
				raise_built = true
			}
			link.register(entity, stop)
			stop.rotatable = false

			---@type TrainStationData
			local struct = {
				id = entity.unit_number,
				type = "station",
				station = entity,
				stop = stop
			}
			registerStation(struct)

			-- take possession of any linked platforms
			if platform then
				local lookup = getPlatform(platform)
				struct.next = lookup
				-- if platforms are registered in reverse order, fix that by swapping next/previous
				if lookup.previous then
					-- temporarily put station as the "next" item to the first platform; it will be swapped into place
					lookup.next = struct
					while lookup do
						local prev = lookup.previous
						local next = lookup.next
						lookup.previous = next
						lookup.next = prev
						lookup = lookup.next
					end
				else
					-- new head is on the correct end, just record it on the first platform
					lookup.previous = struct
				end
			end
		else
			-- platforms must be adjacent to another platform or a station
			local before = math2d.position.add(entity.position, math2d.position.rotate_vector({0,-7}, entity.direction*45))
			local platform1 = entity.surface.find_entities_filtered{
				name = {station, freight, fluid, empty},
				position = before,
				force = entity.force
			}[1]
			if platform1 and not assertPosition(platform1, before) then
				platform1 = nil
			end

			local behind = math2d.position.add(entity.position, math2d.position.rotate_vector({0,7}, entity.direction*45))
			local platform2 = entity.surface.find_entities_filtered{
				name = {station, freight, fluid, empty},
				position = behind,
				force = entity.force
			}[1]
			if platform2 and not assertPosition(platform2, behind) then
				platform2 = nil
			end

			if not (platform1 or platform2) then
				return denyConstruction(entity, {"message.entity-must-be-placed-next-to-platform",{"entity-name."..entity.name}}, event)
			end

			local lookup1 = platform1 and getPlatformOrStation(platform1)
			local lookup2 = platform2 and getPlatformOrStation(platform2)
			local iterateToEnd = function(step)
				while step.previous do
					step = step.previous
				end
				return step
			end
			local head1 = lookup1 and iterateToEnd(lookup1).type == "station"
			local head2 = lookup2 and iterateToEnd(lookup2).type == "station"
			if head1 and head2 then
				return denyConstruction(entity, {"message.no-double-ended-stations"}, event)
			end
			if not (head1 or haad2) then
				return denyConstruction(entity, {"message.cannot-infer-direction"}, event)
			end

			---@type TrainPlatformData
			local struct = {
				id = entity.unit_number,
				type = "platform",
				platform = entity,
				mode = "input"
			}

			if head1 then
				if lookup1 then
					lookup1.next = struct
					struct.previous = lookup1
				end
				if lookup2 then
					lookup2.previous = struct
					struct.next = lookup2
				end
			else
				if lookup1 then
					lookup1.previous = struct
					struct.next = lookup1
				end
				if lookup2 then
					lookup2.next = struct
					struct.previous = lookup2
				end
			end

			if entity.name == freight then
				local store = entity.surface.create_entity{
					name = entity.name.."-box",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector(storage_pos, entity.direction*45)),
					force = entity.force,
					raise_built = true
				}
				link.register(entity, store)
				io.addConnection(entity, {6.5,-2}, "output", store, defines.direction.east)
				io.addConnection(entity, {6.5,-1}, "input", store, defines.direction.west)
				io.addConnection(entity, {6.5,1}, "input", store, defines.direction.west)
				io.addConnection(entity, {6.5,2}, "output", store, defines.direction.east)
				struct.storage = store
			end
			if entity.name == fluid then
				local tank = entity.surface.create_entity{
					name = entity.name.."-tank",
					position = math2d.position.add(entity.position, math2d.position.rotate_vector(tank_pos, entity.direction*45)),
					direction = entity.direction,
					force = entity.force,
					raise_built = true
				}
				tank.rotatable = false
				link.register(entity, tank)
				struct.storage = tank
				rendering.draw_sprite{
					sprite = "utility.fluid_indication_arrow",
					orientation = ((entity.direction+defines.direction.east)%8)/8,
					render_layer = "arrow",
					target = entity,
					target_offset = math2d.position.rotate_vector({6.5,-2}, entity.direction*45),
					surface = entity.surface,
					only_in_alt_mode = true
				}
				rendering.draw_sprite{
					sprite = "utility.fluid_indication_arrow",
					orientation = ((entity.direction+defines.direction.west)%8)/8,
					render_layer = "arrow",
					target = entity,
					target_offset = math2d.position.rotate_vector({6.5,-1}, entity.direction*45),
					surface = entity.surface,
					only_in_alt_mode = true
				}
				rendering.draw_sprite{
					sprite = "utility.fluid_indication_arrow",
					orientation = ((entity.direction+defines.direction.west)%8)/8,
					render_layer = "arrow",
					target = entity,
					target_offset = math2d.position.rotate_vector({6.5,1}, entity.direction*45),
					surface = entity.surface,
					only_in_alt_mode = true
				}
				rendering.draw_sprite{
					sprite = "utility.fluid_indication_arrow",
					orientation = ((entity.direction+defines.direction.east)%8)/8,
					render_layer = "arrow",
					target = entity,
					target_offset = math2d.position.rotate_vector({6.5,2}, entity.direction*45),
					surface = entity.surface,
					only_in_alt_mode = true
				}
			end

			registerPlatform(struct)
		end
		entity.rotatable = false

		link.register(entity, entity.surface.create_entity{
			name = walkable, -- left side in direction of travel is walkable
			position = math2d.position.add(entity.position, math2d.position.rotate_vector({-4,0}, entity.direction*45)),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		})
		link.register(entity, entity.surface.create_entity{
			name = (entity.name == station or entity.name == empty) and walkable or collision, -- right side is blocked by freight
			position = math2d.position.add(entity.position, math2d.position.rotate_vector({4,0}, entity.direction*45)),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		})
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == station or entity.name == freight or entity.name == fluid or entity.name == empty then
		local struct = getPlatformOrStation(entity)
		if struct then
			if struct.next then
				struct.next.previous = nil
			end
			if struct.previous then
				struct.previous.next = nil
			end
		end
		unregisterPlatformOrStation(entity)
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if entity.name == station or entity.name == freight or entity.name == fluid then
		local struct = getPlatformOrStation(entity)
		-- opening the platform instead opens the storage
		local target
		if struct.type == "station" then
			target = struct.stop
		else
			target = struct.storage
		end
		if target and player.can_reach_entity(target) then
			player.opened = target
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

	if entity.name == freight.."-box" or entity.name == fluid.."-tank" then
		local struct = getPlatformByStorage(entity)
		local unloading = struct.mode == "output"
		-- create additional GUI for switching input/output mode (re-use truck station GUI)
		local gui = player.gui.relative
		if not gui['truck-station-gui'] then
			local frame = gui.add{
				type = "frame",
				name = "truck-station-gui",
				anchor = {
					gui = entity.name == freight.."-box" and defines.relative_gui_type.container_gui or defines.relative_gui_type.storage_tank_gui,
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
end
local function onGuiSwitch(event)
	if event.element.valid and event.element.name == "truck-station-mode-toggle" then
		local player = game.players[event.player_index]
		if player.opened.name == freight.."-box" or player.opened.name == fluid.."-tank" then
			local struct = getPlatformByStorage(player.opened)
			local unload = event.element.switch_state == "right"
			struct.mode = unload and "output" or "input"
		end
	end
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and (event.entity.name == freight.."-box" or event.entity.name == fluid.."-tank") then
		local player = game.players[event.player_index]
		local gui = player.gui.relative['truck-station-gui']
		if gui then gui.destroy() end
	end
end

local function onTick(event)
	for _,struct in pairs(getStationBucket(event.tick)) do
		local head = struct.station
		local stop = struct.stop
		if head.energy > 0 then
			-- each station will "tick" once 45 ticks
			-- one transfer every 45 ticks = 24 seconds for a 32-stack freight car

			local trains = stop.get_train_stop_trains()
			local power = 50 -- MW
			for _,train in pairs(trains) do
				-- each train consumes 25MW normally, plus up to 85MW more to recharge its power
				for _,dir in pairs({"front_movers","back_movers"}) do
					for _,loco in pairs(train.locomotives[dir]) do
						local burner = loco.burner
						if not burner.currently_burning then burner.currently_burning = "train-power" end
						local missing = 85*1000*1000 - burner.remaining_burning_fuel
						power = power + 25 + missing/1000/1000/3*4 -- /3*4 converts the 45-tick period to per-second energy
						burner.remaining_burning_fuel = 85*1000*1000
					end
				end
			end
			head.power_usage = power*1000*1000/60 -- set power usage for the next second based on power consumed in the last second
			head.electric_buffer_size = head.power_usage

			local train = stop.get_stopped_train()
			---@type LuaEntity[]
			local wagons = {}
			-- normalise the direction of the train
			if train then
				local train_is_backwards = math2d.position.distance(head.position, train.front_stock.position)
					> math2d.position.distance(head.position, train.back_stock.position)
				local carriages = train.carriages
				local iteration = train_is_backwards and {#carriages, 1, -1} or {1, #carriages, 1}
				for i=iteration[1],iteration[2],iteration[3] do
					wagons[#wagons+1] = carriages[i]
				end
			end
			local index = 2
			local platform = struct.next
			while platform do
				---@type LuaEntity
				local wagon = wagons[index] or {type="absent"}
				local is_output = platform.mode == "output"
				if platform.platform.name == freight then
					if platform.platform.energy > 0 and wagon.type == "cargo-wagon" then
						local wagoninventory = wagon.get_inventory(defines.inventory.cargo_wagon)
						local storeinventory = platform.storage.get_inventory(defines.inventory.chest)
						-- transfer one item stack
						local from = is_output and wagoninventory or storeinventory
						local to = is_output and storeinventory or wagoninventory
						local target = to.find_empty_stack()
						if target and not from.is_empty() then
							local name = next(from.get_contents())
							local source = from.find_item_stack(name)
							target.swap_stack(source)
						end
						-- disable IO and enable energy drain
						io.toggle(platform.platform, false)
						platform.platform.active = true
					else
						-- wagon not present, enable IO and disable energy drain
						io.toggle(platform.platform, true)
						platform.platform.active = false
					end
				end
				if platform.platform.name == fluid then
					if platform.platform.energy > 0 and wagon.type == "fluid-wagon" then
						-- transfer 50 units of fluid
						local from = is_output and wagon or platform.storage
						local to = is_output and platform.storage or wagon
						local name, amount = next(from.get_fluid_contents())
						if not name then amount = 0 end
						if amount > 50 then amount = 50 end
						if amount > 0 then
							from.remove_fluid{
								name = name,
								amount = to.insert_fluid{
									name = name,
									amount = amount
								}
							}
						end
						-- disable IO and enable energy drain
						platform.storage.direction = (platform.platform.direction + 4) % 8
						platform.platform.active = true
					else
						-- wagon not present, enable IO and disable energy drain
						platform.storage.direction = platform.platform.direction
						platform.platform.active = false
					end
				end

				index = index + 1
				platform = platform.next
			end
		end
	end
end

local function onFastTransfer(event, half)
	local player = game.players[event.player_index]
	local target = player.selected
	if not (target and target.valid and target.name == freight) then return end
	-- just passthru the event to the underlying container
	local realbox = getPlatform(target).storage
	if not realbox then return end
	fastTransfer(player, realbox, half)
end

return bev.applyBuildEvents{
	on_init = function()
		global.trains = global.trains or script_data
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		script_data = global.trains or script_data
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_switch_state_changed] = onGuiSwitch,

		[defines.events.on_tick] = onTick,

		["fast-entity-transfer-hook"] = function(event) onFastTransfer(event, false) end,
		["fast-entity-split-hook"] = function(event) onFastTransfer(event, true) end
	}
}
