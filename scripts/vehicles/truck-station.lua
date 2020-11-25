-- uses global.trucks.stations to list all truck stations
local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")
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
		io.addInput(entity, {-4,3.5}, fuel)
		io.addInput(entity, {0,3.5}, store)
		io.addOutput(entity, {2,3.5}, store, defines.direction.south)
		-- default to Input mode
		io.toggle(entity, {2,3.5}, false)
		entity.rotatable = false
		script_data.stations[entity.unit_number%30][entity.unit_number] = {
			entity = entity,
			mode = "input"
		}
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == base or entity.name == storage or entity.name == fuelbox then
		-- find components
		local floor = entity.name == base and entity or entity.surface.find_entity(base, entity.position)
		local store = entity.name == storage and entity or floor.surface.find_entity(storage, math2d.position.add(floor.position, math2d.position.rotate_vector(storage_pos, floor.direction*45)))
		local fuel = entity.name == fuelbox and entity or floor.surface.find_entity(fuelbox, math2d.position.add(floor.position, math2d.position.rotate_vector(fuelbox_pos, floor.direction*45)))
		if entity.name ~= storage then
			getitems.storage(store, event and event.buffer or nil)
			store.destroy()
		end
		if entity.name ~= fuelbox then
			getitems.storage(fuel, event and event.buffer or nil)
			fuel.destroy()
		end
		io.remove(floor, event)
		script_data.stations[floor.unit_number%30][floor.unit_number] = nil
		if entity.name ~= base then
			floor.destroy()
		end
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == base then
		-- opening the combinator instead opens the storage
		player.opened = event.entity.surface.find_entity(storage, math2d.position.add(event.entity.position, math2d.position.rotate_vector(storage_pos, event.entity.direction*45)))
	end
	if event.gui_type == defines.gui_type.entity and event.entity.name == storage then
		local floor = event.entity.surface.find_entity(base, event.entity.position)
		local struct = script_data.stations[floor.unit_number%30][floor.unit_number]
		local unloading = struct.mode == "output"
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
				style = "inner_frame_in_outer_frame"
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
		if player.opened.name == storage then
			local floor = player.opened.surface.find_entity(base, player.opened.position)
			local struct = script_data.stations[floor.unit_number%30][floor.unit_number]
			local unload = event.element.switch_state == "right"
			struct.mode = unload and "output" or "input"
			io.toggle(floor,{0,3.5},not unload)
			io.toggle(floor,{2,3.5},unload)
		end
	end
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and event.entity.name == storage then
		local player = game.players[event.player_index]
		local gui = player.gui.relative['truck-station-gui']
		if gui then gui.destroy() end
	end
end

local function onTick(event)
	for i,struct in pairs(script_data.stations[event.tick%30]) do
		local station = struct.entity
		local mode = struct.mode
		if station.energy >= 10*1000*1000 then
			-- each station will "tick" once every 30 in-game ticks, ie. every half-second
			-- power consumption is 20MW, so each "tick" consumes 10MJ if a vehicle is present
			local centre = math2d.position.add(station.position, math2d.position.rotate_vector({-0.5,-8}, station.direction*45))
			local vehicles = station.surface.find_entities_filtered{
				name = {"tractor","truck","explorer"},
				area = {{centre.x-4,centre.y-4}, {centre.x+4,centre.y+4}}
			}
			local done = false
			for _,vehicle in pairs(vehicles) do
				if vehicle.speed == 0 then
					local is_output = mode == "output"
					local vehicleinventory = vehicle.get_inventory(defines.inventory.car_trunk)
					local store = station.surface.find_entity(storage, math2d.position.add(station.position, math2d.position.rotate_vector(storage_pos, station.direction*45)))
					local storeinventory = store.get_inventory(defines.inventory.chest)
					local fuel = station.surface.find_entity(fuelbox, math2d.position.add(station.position, math2d.position.rotate_vector(fuelbox_pos, station.direction*45)))
					-- always load fuel if possible
					local fuelinventory = vehicle.get_inventory(defines.inventory.fuel)
					local fuelstore = fuel.get_inventory(defines.inventory.chest)
					if not fuelstore.is_empty() then
						if fuelinventory.can_insert(fuelstore[1]) then
							fuelstore.remove({name=fuelstore[1].name, count=fuelinventory.insert(fuelstore[1])})
						end
					end
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
					-- drain 10MJ
					station.energy = station.energy - 10*1000*1000
					done = true
					break
				end
			end
			-- disable input if a vehicle is present, enable it if not
			io.toggle(station,{0,3.5},not done)
		end
	end
end

return {
	on_init = function()
		global.trucks = global.trucks or script_data
	end,
	on_load = function()
		script_data = global.trucks or script_data
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
		[defines.events.on_gui_switch_state_changed] = onGuiSwitch,

		[defines.events.on_tick] = onTick
	}
}
