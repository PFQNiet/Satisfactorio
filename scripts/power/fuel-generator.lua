-- it is a storage tank with attached electric energy interface
-- periodically removes fluid from the tank to recharge the electricity buffer
-- uses global['fuel-generators'] to list all gens
local powertrip = require(modpath.."scripts.lualib.power-trip")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local storage = "fuel-generator"
local buffer = storage.."-eei"
local accumulator = storage.."-buffer"
local power = 150

---@class FuelGeneratorData
---@field generator LuaEntity
---@field interface LuaEntity

---@alias FuelGeneratorBucket table<uint, FuelGeneratorData>
---@alias global.fuel_generators FuelGeneratorBucket[]
---@type global.fuel_generators
local script_data = {}
local buckets = 60
for i=0,buckets-1 do script_data[i] = {} end
local function getBucket(tick)
	return script_data[tick%buckets]
end

---@param entity LuaEntity
local function createStruct(entity)
	local pow = entity.surface.create_entity{
		name = buffer,
		position = entity.position,
		force = entity.force,
		raise_built = true
	}
	local struct = {
		generator = entity,
		interface = pow
	}
	link.register(entity, pow)

	powertrip.registerGenerator(entity, pow, accumulator)
	script_data[entity.unit_number%buckets][entity.unit_number] = struct
end
---@param entity LuaEntity
local function deleteStruct(entity)
	script_data[entity.unit_number%buckets][entity.unit_number] = nil
end

---@param entity LuaEntity
local function onBuilt(entity)
	createStruct(entity)
end

---@param entity LuaEntity
local function onRemoved(entity)
	deleteStruct(entity)
end

---@param event on_tick
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
		local eei = struct.interface
		if eei.active then
			if struct.generator.is_crafting() then
				eei.power_production = (power*1000*1000+1)/60 -- +1 for the buffer
			else
				eei.power_production = 0
			end
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.fuel_generators = global.fuel_generators or script_data
	end,
	on_load = function()
		script_data = global.fuel_generators or script_data
	end,
	on_build = {
		callback = onBuilt,
		filter = {name=storage}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name=storage}
	},
	events = {
		[defines.events.on_tick] = onTick
	}
}
