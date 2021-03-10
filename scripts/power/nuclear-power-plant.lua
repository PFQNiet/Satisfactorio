local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local math2d = require("math2d")
local powertrip = require(modpath.."scripts.lualib.power-trip")

local boiler = "nuclear-power-plant"
local buffer = boiler.."-eei"
local accumulator = boiler.."-buffer"
local energy = "energy"
local waste = "nuclear-waste"

local script_data = {generators = {}, consumed = {}}
for i=0,60-1 do script_data.generators[i] = {} end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == boiler then
		io.addInput(entity, {-2,10})
		io.addOutput(entity, {2,10}, nil, defines.direction.south)
		entity.rotatable = false
		local eei = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		eei.rotatable = false
		powertrip.registerGenerator(entity, eei, accumulator)
		script_data.generators[entity.unit_number%60][entity.unit_number] = entity
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == boiler or entity.name == buffer then
		local store = entity.name == boiler and entity or entity.surface.find_entity(boiler, entity.position)
		local gen = entity.name == buffer and entity or entity.surface.find_entity(buffer, entity.position)
		script_data.generators[store.unit_number%60][store.unit_number] = nil
		powertrip.unregisterGenerator(store)
		io.remove(store, event)
		if entity.name ~= boiler then
			store.destroy()
		end
		if entity.name ~= buffer then
			gen.destroy()
		end
	end
end

local function onTick(event)
	for i,storage in pairs(script_data.generators[event.tick%60]) do
		-- each station will "tick" once every 60 in-game ticks, ie. every second
		-- power production is 2.5GW, so each "tick" can buffer up to 2.5GW given enough fuel
		local eei = storage.surface.find_entity(buffer, storage.position)
		if eei.active then
			local fluid_amount = storage.get_fluid_count(energy)
			-- each unit of "energy" is 1MW
			local max_power = 2500
			-- attempt to remove the full amount - if it's limited by the amount actually present then the return value will reflect that
			local available = storage.remove_fluid{name=energy, amount=max_power}
			eei.power_production = (available*1000*1000+1)/60 -- convert to joules-per-tick

			local consumed = script_data.consumed[storage.unit_number] or 0
			consumed = consumed + available
			-- every 12 ticks of full consumption, produce one nuclear waste
			if consumed > 2500 * 12 then
				consumed = consumed - 2500 * 12
				storage.get_inventory(defines.inventory.assembling_machine_output).insert({name=waste,count=1})
				storage.force.item_production_statistics.on_flow(waste,1)
			end
			script_data.consumed[storage.unit_number] = consumed
		end
	end
end
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.entity and event.entity.valid and event.entity.name == buffer then
		-- opening the EEI instead opens the tank
		player.opened = event.entity.surface.find_entity(boiler, event.entity.position)
	end
end

return {
	on_init = function()
		global.nuclear_generators = global.nuclear_generators or script_data.generators
		global.nuclear_generator_waste = global.nuclear_generator_waste or script_data.consumed
	end,
	on_load = function()
		script_data.generators = global.nuclear_generators or script_data.generators
		script_data.consumed = global.nuclear_generator_waste or script_data.consumed
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

		[defines.events.on_tick] = onTick,
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
