-- track built generators and place a fake accumulator on top of them
-- if the accumulator ever runs out of power, then the network is overdrawn and should be shut down
-- generators on the network are disabled, and a GUI allows re-enabling them

-- uses global.power_trip.accumulators to track the hidden accumulators
-- uses global.power_trip.last_outage to track per-force when the last power outage was, to de-duplicate FX

local table_size = table_size
local script_data = {
	accumulators = {},
	last_outage = {}
}

local function registerGenerator(burner, generator, accumulator_name)
	local accumulator = generator.surface.create_entity{
		name = accumulator_name,
		position = generator.position,
		force = generator.force,
		raise_built = true
	}
	accumulator.energy = 1
	accumulator.minable = false
	accumulator.operable = false
	accumulator.destructible = false

	local struct = {
		burner = burner,
		generator = generator,
		accumulator = accumulator,
		active = true
	}
	-- store the struct under the index of the accumulator, and record the burner and generator as pointers to it
	if burner then script_data.accumulators[burner.unit_number] = accumulator.unit_number end
	script_data.accumulators[generator.unit_number] = accumulator.unit_number
	script_data.accumulators[accumulator.unit_number] = struct
end
local function findRegistration(entity)
	if table_size(script_data.accumulators) == 0 then return nil end
	-- look up a struct based on any of its components
	local lookup = script_data.accumulators[entity.unit_number]
	if type(lookup) == "number" then
		-- pointer to the accumulator
		lookup = script_data.accumulators[lookup]
	end
	return lookup
end
local function unregisterGenerator(entity)
	local struct = findRegistration(entity)
	if struct.burner then script_data.accumulators[struct.burner.unit_number] = nil end
	script_data.accumulators[struct.generator.unit_number] = nil
	script_data.accumulators[struct.accumulator.unit_number] = nil
	struct.accumulator.destroy()
end

local function createFusebox(player)
	local gui = player.gui.left
	if not gui['power-trip-reset-fuse'] then
		local frame = gui.add{
			type = "frame",
			name = "power-trip-reset-fuse",
			direction = "vertical",
			caption = {"gui.power-trip-reset-fuse-title"},
			style = "inner_frame_in_outer_frame"
		}
		frame.style.horizontally_stretchable = false
		frame.style.use_header_filler = false
		local bottom = frame.add{type="flow"}
		local pusher = bottom.add{type="empty-widget"}
		pusher.style.horizontally_stretchable = true
		bottom.add{
			type = "button",
			style = "confirm_button",
			name = "power-trip-reset-fuse-submit",
			caption = {"gui.power-trip-reset-fuse-button"}
		}
	end
end
local function toggle(entry, enabled)
	if entry.burner then entry.burner.active = enabled end
	entry.generator.active = enabled
	entry.active = enabled

end
local function onTick(event)
	for _,entry in pairs(script_data.accumulators) do
		if type(entry) == "table" then -- skip numeric pointers
			if entry.generator.active and entry.accumulator.energy == 0 then
				-- don't count running out of fuel as a power trip
				if entry.burner and entry.burner.burner and entry.burner.burner.remaining_burning_fuel == 0 then
					-- just ran out of fuel
				elseif entry.burner and entry.burner.type == "storage-tank" and entry.burner.get_fluid_count() == 0 then
					-- likewise, ran out of fuel
				else
					-- power failure!
					toggle(entry,false)
					local force = entry.accumulator.force
					if not script_data.last_outage[force.index] then script_data.last_outage[force.index] = -5000 end
					if script_data.last_outage[force.index]+60 < event.tick then
						-- only play sound at most once a second
						force.play_sound{path="power-failure"}
					end
					if script_data.last_outage[force.index]+3600 < event.tick then
						-- only show console message at most once a minute
						force.print({"message.power-failure"})
					end
					script_data.last_outage[force.index] = event.tick
					-- see if any player on this entity's force has this generator opened
					for _,player in pairs(force.players) do
						if player.opened and (player.opened == entry.burner or player.opened == entry.generator) then
							createFusebox(player)
						end
					end
				end
			end
		end
	end
end

local function onGuiOpened(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entry = findRegistration(event.entity)
	if not entry then return end
	if entry.active then return end
	local player = game.players[event.player_index]
	createFusebox(player)
end
local function onGuiClosed(event)
	local player = game.players[event.player_index]
	local gui = player.gui.left
	if gui['power-trip-reset-fuse'] then
		gui['power-trip-reset-fuse'].destroy()
	end
end
local function onGuiClick(event)
	local player = game.players[event.player_index]
	if event.element and event.element.valid and event.element.name == "power-trip-reset-fuse-submit" then
		-- get electric network ID of opened GUI
		if not player.opened then return end
		local entry = findRegistration(player.opened)
		if not entry then return end
		local force = entry.generator.force
		local network = entry.generator.electric_network_id
		local fl_proto = game.fluid_prototypes
		-- seek out all generators with this network ID and re-enable them
		for _,entry in pairs(script_data.accumulators) do
			if type(entry) == "table" then -- ignore pointers to accumulators, just do actual entries
				if entry.generator.force == force and entry.generator.electric_network_id == network then
					toggle(entry, true)
					if entry.burner and entry.burner.type == "storage-tank" then
						-- immediately perform a fuel transfer
						local fluid_type, fluid_amount = next(entry.burner.get_fluid_contents())
						if fluid_type and fluid_amount > 0 then
							local fuel_value = fl_proto[fluid_type].fuel_value
							if fuel_value > 0 then
								local energy_to_full_charge = entry.generator.electric_buffer_size - entry.generator.energy
								local fuel_to_full_charge = energy_to_full_charge / fuel_value
								-- attempt to remove the full amount - if it's limited by the amount actually present then the return value will reflect that
								local fuel_consumed_this_tick = entry.burner.remove_fluid{name=fluid_type, amount=fuel_to_full_charge}
								local energy_gained_this_tick = fuel_consumed_this_tick * fuel_value
								entry.generator.energy = entry.generator.energy + energy_gained_this_tick
							end
						end
					end
					entry.accumulator.energy = 1
				end
			end
		end
		-- set last power outage time to a short moment in the past, so that the sound effect can still play if it insta-trips again but the console message won't appear
		script_data.last_outage[player.force.index] = event.tick-600
		player.force.play_sound{path="power-startup"}
		onGuiClosed(event)
	end
end

return {
	registerGenerator = registerGenerator,
	unregisterGenerator = unregisterGenerator,
	lib = {
		on_init = function()
			global.power_trip = global.power_trip or script_data
		end,
		on_load = function()
			script_data = global.power_trip or script_data
		end,
		on_configuration_changed = function()
			if global['accumulators'] then
				global.power_trip.accumulators = table.deepcopy(global['accumulators'])
				global['accumulators'] = nil
			end
			if global['last-power-trip'] then
				global.power_trip.last_outage = table.deepcopy(global['last-power-trip'])
				global['last-power-trip'] = nil
			end
		end,
		on_nth_tick = {
			[60] = onTick
		},
		events = {
			[defines.events.on_gui_opened] = onGuiOpened,
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	},
}
