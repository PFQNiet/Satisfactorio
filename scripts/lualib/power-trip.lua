-- track built generators and place a fake accumulator on top of them
-- if the accumulator ever runs out of power, then the network is overdrawn and should be shut down
-- generators on the network are disabled, and a GUI allows re-enabling them

-- uses global['accumulators'] to track the hidden accumulators
-- uses global['last-power-trip'] to track per-force when the last power outage was, to de-duplicate FX
local gui = require("mod-gui")

local function registerGenerator(burner, generator, accumulator_name)
	-- components, if passed, should always start with the entity that takes the fuel (for Fusebox use)
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
	if not global['accumulators'] then global['accumulators'] = {} end
	if not global['accumulators'][burner.surface.index] then global['accumulators'][burner.surface.index] = {} end
	if not global['accumulators'][burner.surface.index][burner.position.y] then global['accumulators'][burner.surface.index][burner.position.y] = {} end
	global['accumulators'][burner.surface.index][burner.position.y][burner.position.x] = {
		burner = burner,
		generator = generator,
		accumulator = accumulator
	}
end
local function unregisterGenerator(burner)
	local row = global['accumulators'][burner.surface.index][burner.position.y]
	local entry = row[burner.position.x]
	if entry then
		row[burner.position.x] = nil
		entry.accumulator.destroy()
	end
end
local function isRegistered(burner)
	if not global['accumulators'] then return false end
	if not global['accumulators'][burner.surface.index] then return false end
	if not global['accumulators'][burner.surface.index][burner.position.y] then return false end
	if not global['accumulators'][burner.surface.index][burner.position.y][burner.position.x] then return false end
	return true
end

local function createFusebox(player)
	local gui = player.gui.left
	if not gui['power-trip-reset-fuse'] then
		local frame = gui.add{
			type = "frame",
			name = "power-trip-reset-fuse",
			direction = "vertical",
			caption = {"gui.power-trip-reset-fuse-title"},
			style = mod_gui.frame_style
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
	entry.burner.active = enabled
	entry.generator.active = enabled
end
local function onTick(event)
	if not global['accumulators'] then return end
	for surface, rows in pairs(global['accumulators']) do
		for y, row in pairs(rows) do
			for x, entry in pairs(row) do
				-- don't count running out of fuel as a power trip
				if entry.burner.active and entry.burner.burner.remaining_burning_fuel > 0 and entry.accumulator.energy == 0 then
					-- power failure!
					toggle(entry,false)
					if not global['last-power-trip'] then global['last-power-trip'] = {} end
					if not global['last-power-trip'][entry.burner.force.index] then global['last-power-trip'][entry.burner.force.index] = -5000 end
					if global['last-power-trip'][entry.burner.force.index]+60 < event.tick then
						-- only play sound at most once a second
						entry.burner.force.play_sound{path="power-failure"}
					end
					if global['last-power-trip'][entry.burner.force.index]+3600 < event.tick then
						-- only show console message at most once a minute
						entry.burner.force.print({"message.power-failure"})
					end
					global['last-power-trip'][entry.burner.force.index] = event.tick
					-- see if any player on this entity's force has this generator opened
					for _,player in pairs(entry.burner.force.players) do
						if player.opened and player.opened == entry.burner then
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
	if not isRegistered(event.entity) then return end
	if event.entity.active then return end
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
		if not isRegistered(player.opened) then return end
		local network = global['accumulators'][player.opened.surface.index][player.opened.position.y][player.opened.position.x].generator.electric_network_id
		-- seek out all generators with this network ID and re-enable them
		for surface, rows in pairs(global['accumulators']) do
			for y, row in pairs(rows) do
				for x, entry in pairs(row) do
					if entry.generator.electric_network_id == network then
						toggle(entry, true)
						entry.accumulator.energy = 1
					end
				end
			end
		end
		-- set last power outage time to a short moment in the past, so that the sound effect can still play if it insta-trips again but the console message won't appear
		global['last-power-trip'][player.force.index] = event.tick-600
		player.force.play_sound{path="power-startup"}
		onGuiClosed(event)
	end
end

return {
	lib = {
		on_nth_tick = {
			[60] = onTick
		},
		events = {
			[defines.events.on_gui_opened] = onGuiOpened,
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	},
	registerGenerator = registerGenerator,
	unregisterGenerator = unregisterGenerator
}