-- track built generators and place a fake accumulator on top of them
-- if the accumulator ever runs out of power, then the network is overdrawn and should be shut down
-- generators on the network are disabled, and a GUI allows re-enabling them

-- uses global['accumulators'] to track the hidden accumulators
-- uses global['last-power-trip'] to track per-force when the last power outage was, to de-duplicate FX
local gui = require("mod-gui")

local generator_data = {
	["biomass-burner-hub"] = {
		accumulator = "biomass-burner-hub-accumulator"
	},
	["biomass-burner"] = {
		accumulator = "biomass-burner-accumulator"
	}
}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if not generator_data[entity.name] then return end
	if not global['accumulators'] then global['accumulators'] = {} end
	
	local gen = generator_data[entity.name]
	local accumulator = entity.surface.create_entity{
		name = gen[entity.direction] or gen.accumulator,
		position = entity.position,
		force = entity.force,
		raise_built = true
	}
	accumulator.energy = 1
	accumulator.minable = false
	accumulator.operable = false
	accumulator.destructible = false
	if not global['accumulators'][entity.surface.index] then global['accumulators'][entity.surface.index] = {} end
	if not global['accumulators'][entity.surface.index][entity.position.y] then global['accumulators'][entity.surface.index][entity.position.y] = {} end
	global['accumulators'][entity.surface.index][entity.position.y][entity.position.x] = {generator=entity, accumulator=accumulator}
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if not generator_data[entity.name] then return end

	local row = global['accumulators'][entity.surface.index][entity.position.y]
	local entry = row[entity.position.x]
	row[entity.position.x] = nil

	entry.accumulator.destroy()
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
local function onTick(event)
	if not global['accumulators'] then return end
	for surface, rows in pairs(global['accumulators']) do
		for y, row in pairs(rows) do
			for x, entry in pairs(row) do
				-- don't count running out of fuel as a power trip
				if entry.generator.active and entry.generator.burner.remaining_burning_fuel > 0 and entry.accumulator.energy == 0 then
					-- power failure!
					entry.generator.active = false
					if not global['last-power-trip'] then global['last-power-trip'] = {} end
					if not global['last-power-trip'][entry.generator.force.index] then global['last-power-trip'][entry.generator.force.index] = -5000 end
					if global['last-power-trip'][entry.generator.force.index]+60 < event.tick then
						-- only play sound at most once a second
						entry.generator.force.play_sound{path="power-failure"}
					end
					if global['last-power-trip'][entry.generator.force.index]+3600 < event.tick then
						-- only show console message at most once a minute
						entry.generator.force.print({"message.power-failure"})
					end
					global['last-power-trip'][entry.generator.force.index] = event.tick
					-- see if any player on this entity's force has this generator opened
					for _,player in pairs(entry.generator.force.players) do
						if player.opened and player.opened == entry.generator then
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
	if not generator_data[event.entity.name] then return end
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
	if event.element.name == "power-trip-reset-fuse-submit" then
		-- get electric network ID of opened GUI
		if not player.opened then return end
		if not generator_data[player.opened.name] then return end
		local network = global['accumulators'][player.opened.surface.index][player.opened.position.y][player.opened.position.x].generator.electric_network_id
		-- seek out all generators with this network ID and re-enable them
		for surface, rows in pairs(global['accumulators']) do
			for y, row in pairs(rows) do
				for x, entry in pairs(row) do
					if entry.generator.electric_network_id == network then
						entry.generator.active = true
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
	on_nth_tick = {
		[60] = onTick
	},
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
		[defines.events.on_gui_click] = onGuiClick
	}
}
