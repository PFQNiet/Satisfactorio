-- track built generators and place a 1W drain on top of them
-- if the drain ever runs low on power, then the network is overdrawn and should be shut down
-- generators on the network are disabled, and a GUI allows re-enabling them

local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

---@class GeneratorData
---@field burner LuaEntity|nil The entity containing the fuel; not set for geothermal-generators
---@field generator LuaEntity The entity that produces power
---@field accumulator LuaEntity The 1W drain placed by this system
---@field active boolean

---@class global.power_trip
---@field accumulators table<uint, GeneratorData>
---@field pointers table<uint, uint> Map burner/generator ID to accumulator ID
---@field last_outage table<uint, uint> Map force ID to tick of last power outage, for debouncing
local script_data = {
	accumulators = {},
	pointers = {},
	last_outage = {}
}

---@param burner LuaEntity|nil
---@param generator LuaEntity
---@param accumulator_name string
local function registerGenerator(burner, generator, accumulator_name)
	local accumulator = generator.surface.create_entity{
		name = accumulator_name,
		position = generator.position,
		direction = generator.direction,
		force = generator.force,
		raise_built = true
	}
	accumulator.energy = 1
	link.register(generator, accumulator)

	local struct = {
		burner = burner,
		generator = generator,
		accumulator = accumulator,
		active = true
	}
	-- store the struct under the index of the accumulator, and record the burner and generator as pointers to it
	if burner then script_data.pointers[burner.unit_number] = accumulator.unit_number end
	script_data.pointers[generator.unit_number] = accumulator.unit_number
	script_data.accumulators[accumulator.unit_number] = struct
end
---@param entity LuaEntity
local function findRegistration(entity)
	local lookup = entity.unit_number
	if script_data.pointers[lookup] then
		lookup = script_data.pointers[lookup]
	end
	return script_data.accumulators[lookup]
end
---@param entity LuaEntity
local function unregisterGenerator(entity)
	local struct = findRegistration(entity)
	if not struct then return end
	if struct.burner then script_data.pointers[struct.burner.unit_number] = nil end
	script_data.pointers[struct.generator.unit_number] = nil
	script_data.accumulators[struct.accumulator.unit_number] = nil
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	unregisterGenerator(entity)
end

---@param player LuaPlayer
local function createFusebox(player)
	local gui = player.gui.relative
	if not gui['fusebox'] then
		local flow = gui.add{
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
			style = "submit_button",
			name = "fusebox-reset-fuse",
			caption = {"gui.power-trip-reset-fuse-button"}
		}
	end
	local flow = gui['fusebox']
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

---@param entry GeneratorData
---@param enabled boolean
local function toggle(entry, enabled)
	if entry.burner then entry.burner.active = enabled end
	entry.generator.active = enabled
	entry.active = enabled
end

---@param event NthTickEventData
local function on60thTick(event)
	for _,entry in pairs(script_data.accumulators) do
		if entry.generator.active and entry.accumulator.energy > 0 and entry.accumulator.energy < entry.accumulator.electric_buffer_size*0.999 then
			-- don't count running out of fuel as a power trip
			if entry.burner and entry.burner.burner and entry.burner.burner.remaining_burning_fuel == 0 then
				-- just ran out of fuel
			else
				-- power failure!
				toggle(entry,false)
				-- this will cause a chain-reaction as other generators will have insufficient energy too
				local force = entry.accumulator.force
				if not script_data.last_outage[force.index] then script_data.last_outage[force.index] = -5000 end
				if script_data.last_outage[force.index]+60 < event.tick then
					-- only play sound at most once a second
					force.play_sound{path="power-failure"}
				end
				if script_data.last_outage[force.index]+3600 < event.tick then
					-- only show console message at most once a minute
					force.print({"message.power-failure"})
					-- set "invisible" tech to researched to unlock tip/trick
					force.technologies['tips-and-tricks-power-trip'].researched = true
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

---@param event on_gui_opened
local function onGuiOpened(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entry = findRegistration(event.entity)
	if not entry then return end
	if entry.active then return end
	local player = game.players[event.player_index]
	createFusebox(player)
end
---@param event on_gui_closed
local function onGuiClosed(event)
	local player = game.players[event.player_index]
	local gui = player.gui.relative
	if gui['fusebox'] then
		gui['fusebox'].destroy()
	end
end
---@param event on_gui_click
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
		for _,other in pairs(script_data.accumulators) do
			if other.generator.force == force and other.generator.electric_network_id == network then
				toggle(other, true)
				other.accumulator.energy = other.accumulator.electric_buffer_size
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

	lib = bev.applyBuildEvents{
		on_init = function()
			global.power_trip = global.power_trip or script_data
		end,
		on_load = function()
			script_data = global.power_trip or script_data
		end,
		on_nth_tick = {
			[60] = on60thTick
		},
		on_destroy = onRemoved,
		events = {
			[defines.events.on_gui_opened] = onGuiOpened,
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
