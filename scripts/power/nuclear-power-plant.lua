local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local math2d = require("math2d")
local powertrip = require(modpath.."scripts.lualib.power-trip")

local boiler = "nuclear-power-plant"
local buffer = boiler.."-eei"
local accumulator = boiler.."-buffer"
local energy = "energy"

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

local WASTE = {
	["uranium-fuel-rod"] = {
		name = "uranium-waste",
		amount = 6 -- seconds per waste
	},
	["plutonium-fuel-rod"] = {
		name = "plutonium-waste",
		amount = 60 -- seconds per waste
	}
}
local function onTick(event)
	for i,storage in pairs(script_data.generators[event.tick%60]) do
		-- each station will "tick" once every 60 in-game ticks, ie. every second
		-- if the machine is crafting then output power, and don't if not
		-- if it is running, increment the counter of "running" cycles and if it crosses the threshold then generate waste
		-- power production is 2.5GW
		local eei = storage.surface.find_entity(buffer, storage.position)
		if eei.active then
			if storage.is_crafting() then
				eei.power_production = (2500*1000*1000+1)/60 -- 2.5GW, +1 for the buffer

				local consumed = script_data.consumed[storage.unit_number] or 0
				consumed = consumed + 1
				if storage.burner.currently_burning then
					local fuel = storage.burner.currently_burning.name
					if fuel and WASTE[fuel] then
						if consumed >= WASTE[fuel].amount then
							consumed = consumed - WASTE[fuel].amount
							storage.get_inventory(defines.inventory.assembling_machine_output).insert({name=WASTE[fuel].name,count=1})
							storage.force.item_production_statistics.on_flow(WASTE[fuel].name,1)
						end
					end
				end
				script_data.consumed[storage.unit_number] = consumed
			else
				eei.power_production = 0
			end
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
