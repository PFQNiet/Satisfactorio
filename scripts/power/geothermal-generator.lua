-- uses global.geogens to track generators for power cycling
local powertrip = require(modpath.."scripts.lualib.power-trip")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local miner = "geothermal-generator"
local gen = miner.."-eei"
local accumulator = miner.."-buffer"
local basepower = 100 -- average power generation in MW for an Impure geyser (100% yield)

---@class GeothermalGeneratorData
---@field interface LuaEntity
---@field power number[]
---@field time_offset number

---@alias GeothermalGeneratorBucket table<uint, GeothermalGeneratorData>
---@alias global.geogens GeothermalGeneratorBucket[]
---@type global.geogens
local script_data = {}
local buckets = 60
for i=0,buckets-1 do script_data[i] = {} end
local function getBucket(tick)
	return script_data[tick%buckets]
end

---@param entity LuaEntity
local function createStruct(entity)
	local node = entity.surface.find_entity("geyser", entity.position)
	-- replace miner with generator
	local pow = entity.surface.create_entity{
		name = gen,
		position = entity.position,
		force = entity.force,
		raise_built = true
	}
	local purity = node.amount / 60
	local struct = {
		interface = pow,
		power = {basepower*purity*0.5, basepower*purity*1.5},
		time_offset = math.random(0,2*60*60) -- shift time by up to 2 minutes
	}
	entity.destroy()
	pow.electric_buffer_size = (struct.power[2] * 1000 * 1000 + 1) / 60

	powertrip.registerGenerator(nil, pow, accumulator)
	script_data[pow.unit_number%buckets][pow.unit_number] = struct
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
		-- power consumption ranges based on the resource node, in a sine wave, over a minute-long cycle
		local min = struct.power[1]
		local max = struct.power[2]
		local t = (event.tick + struct.time_offset) / (60 * 60) * math.pi
		local pow = (min + max) / 2 + (max - min) / 2 * math.sin(t)
		struct.interface.power_production = (pow * 1000 * 1000 + 1) / 60 -- MW to joules-per-tick, plus one for the buffer
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.geogens = global.geogens or script_data
	end,
	on_load = function()
		script_data = global.geogens or script_data
	end,
	on_build = {
		callback = onBuilt,
		filter = {name=miner}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name=gen}
	},
	events = {
		[defines.events.on_tick] = onTick
	}
}
