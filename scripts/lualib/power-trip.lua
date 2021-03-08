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
	local gui = player.gui.relative
	local flow = gui['fusebox']
	if not flow then
		flow = gui.add{
			type = "flow",
			name = "fusebox",
			anchor = {
				gui = defines.relative_gui_type.entity_with_energy_source_gui,
				position = defines.relative_gui_position.bottom
			},
			direction = "horizontal"
		}
		flow.add{type="empty-widget"}.style.horizontally_stretchable = true
		local frame = flow.add{
			type = "frame",
			name = "content",
			direction = "vertical",
			caption = {"gui.power-trip-reset-fuse-title"},
			style = "inset_frame_container_frame"
		}
		frame.style.horizontally_stretchable = false
		frame.style.use_header_filler = false
		frame.add{
			type = "button",
			style = "confirm_button",
			name = "fusebox-reset-fuse",
			caption = {"gui.power-trip-reset-fuse-button"}
		}
	end
	local frame = flow.content
	local types = {
		["burner-generator"] = "entity_with_energy_source_gui",
		["electric-energy-interface"] = "electric_energy_interface_gui",
		["furnace"] = "furnace_gui",
		["default"] = "assembling_machine_gui"
	}
	flow.anchor = {
		gui = defines.relative_gui_type[types[player.opened and player.opened.type or "default"] or types["default"]],
		position = defines.relative_gui_position.bottom
	}
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
	local gui = player.gui.relative
	if gui['fusebox'] then
		gui['fusebox'].destroy()
	end
end
local function onGuiClick(event)
	local player = game.players[event.player_index]
	if event.element and event.element.valid and event.element.name == "fusebox-reset-fuse" then
		-- get electric network ID of opened GUI
		if not player.opened then return end
		local entry = findRegistration(player.opened)
		if not entry then return end
		local force = entry.generator.force
		local network = entry.generator.electric_network_id
		-- seek out all generators with this network ID and re-enable them
		for _,entry in pairs(script_data.accumulators) do
			if type(entry) == "table" then -- ignore pointers to accumulators, just do actual entries
				if entry.generator.force == force and entry.generator.electric_network_id == network then
					toggle(entry, true)
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

	on_init = function()
		global.power_trip = global.power_trip or script_data
	end,
	on_load = function()
		script_data = global.power_trip or script_data
	end,
	on_nth_tick = {
		[60] = onTick
	},
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick
	}
}
