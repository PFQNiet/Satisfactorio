-- it is a storage tank with attached electric energy interface
-- periodically removes fluid from the tank to recharge the electricity buffer
-- uses global['fuel-generators'] to list all gens
local math2d = require("math2d")
local powertrip = require("scripts.lualib.power-trip")

local storage = "fuel-generator"
local buffer = storage.."-eei"
local accumulator = storage.."-accumulator"

local script_data = {}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == storage then
		-- add EEI
		local eei = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		entity.rotatable = false
		eei.rotatable = false
		powertrip.registerGenerator(entity, eei, accumulator)
		script_data[entity.unit_number] = entity
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == storage or entity.name == buffer then
		-- find components
		local store = entity.name == storage and entity or entity.surface.find_entity(storage, entity.position)
		local gen = entity.name == buffer and entity or entity.surface.find_entity(buffer, entity.position)
		script_data[store.unit_number] = nil
		powertrip.unregisterGenerator(store)
		if entity.name ~= storage then
			store.destroy()
		end
		if entity.name ~= buffer then
			gen.destroy()
		end
	end
end

local function onTick(event)
	for i,storage in pairs(script_data) do
		if event.tick%60 == i%60 then
			-- each station will "tick" once every 60 in-game ticks, ie. every second
			-- power production is 150MW, so each "tick" can buffer up to 150MJ given enough fuel
			local eei = storage.surface.find_entity(buffer, storage.position)
			local fluid_type, fluid_amount = next(storage.get_fluid_contents())
			if fluid_type and fluid_amount > 0 and eei.active then
				local fuel_value = game.fluid_prototypes[fluid_type].fuel_value
				if fuel_value > 0 then
					local energy_to_full_charge = eei.electric_buffer_size - eei.energy
					local fuel_to_full_charge = energy_to_full_charge / fuel_value
					-- attempt to remove the full amount - if it's limited by the amount actually present then the return value will reflect that
					local fuel_consumed_this_tick = storage.remove_fluid{name=fluid_type, amount=fuel_to_full_charge}
					local energy_gained_this_tick = fuel_consumed_this_tick * fuel_value
					eei.energy = eei.energy + energy_gained_this_tick
				end
			end
		end
	end
end
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.entity and event.entity.valid and event.entity.name == buffer then
		-- opening the EEI instead opens the tank
		player.opened = event.entity.surface.find_entity(storage, event.entity.position)
	end
end

return {
	on_init = function()
		global.fuel_generators = global.fuel_generators or script_data
	end,
	on_load = function()
		script_data = global.fuel_generators or script_data
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
