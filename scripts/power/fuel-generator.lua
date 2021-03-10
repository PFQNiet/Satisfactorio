-- it is a storage tank with attached electric energy interface
-- periodically removes fluid from the tank to recharge the electricity buffer
-- uses global['fuel-generators'] to list all gens
local math2d = require("math2d")
local powertrip = require(modpath.."scripts.lualib.power-trip")

local storage = "fuel-generator"
local buffer = storage.."-eei"
local accumulator = storage.."-buffer"
local energy = "energy"

local script_data = {}
for i=0,60-1 do script_data[i] = {} end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == storage then
		entity.fluidbox[2] = {name=energy,amount=0.1} -- avoid auto-flush
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
		script_data[entity.unit_number%60][entity.unit_number] = entity
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == storage or entity.name == buffer then
		-- find components
		local store = entity.name == storage and entity or entity.surface.find_entity(storage, entity.position)
		local gen = entity.name == buffer and entity or entity.surface.find_entity(buffer, entity.position)
		script_data[store.unit_number%60][store.unit_number] = nil
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
	for i,storage in pairs(script_data[event.tick%60]) do
		-- each station will "tick" once every 60 in-game ticks, ie. every second
		-- power production is 150MW, so each "tick" can buffer up to 150MJ given enough fuel
		local eei = storage.surface.find_entity(buffer, storage.position)
		if eei.active then
			local fluid_amount = storage.get_fluid_count(energy)
			-- each unit of "energy" is 1GW
			local max_power = 0.15
			local fluidbox = storage.fluidbox[2] -- output box
			if fluidbox then
				local amount = math.max(0, math.min(max_power, fluidbox.amount - 0.1)) -- epsilon to avoid auto-flush
				fluidbox.amount = fluidbox.amount - amount
				storage.fluidbox[2] = fluidbox
				eei.power_production = (amount*1000*1000*1000+1)/60 -- convert to joules-per-tick, +1 for the buffer
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
		player.opened = event.entity.surface.find_entity(storage, event.entity.position)
	end
	-- TODO add Flush button to the tank
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
