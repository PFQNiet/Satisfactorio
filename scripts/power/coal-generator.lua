local io = require(modpath.."scripts.lualib.input-output")
local powertrip = require(modpath.."scripts.lualib.power-trip")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local boiler = "coal-generator"
local buffer = "coal-generator-eei"
local accumulator = "coal-generator-buffer"
local power = 75

---@class CoalGeneratorData
---@field generator LuaEntity
---@field interface LuaEntity

---@alias CoalGeneratorBucket table<uint, CoalGeneratorData>
---@alias global.coal_generators CoalGeneratorBucket[]
---@type global.coal_generators
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
		direction = entity.direction,
		force = entity.force,
		raise_built = true
	}
	pow.rotatable = false

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
	io.addConnection(entity, {1,5.5}, "input")
	createStruct(entity)
end

---@param entity LuaEntity
local function onRemoved(entity)
	deleteStruct(entity)
end

---@param event on_tick
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
		-- if the machine is crafting then output power, and don't if not
		local eei = struct.interface
		if eei.active then
			if struct.generator.burner.currently_burning and struct.generator.is_crafting() then
				eei.power_production = (power*1000*1000+1)/60 -- +1 for the buffer
			else
				eei.power_production = 0
			end
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.coal_generators = global.coal_generators or script_data
	end,
	on_load = function()
		script_data = global.coal_generators or script_data
	end,
	on_build = {
		callback = onBuilt,
		filter = {name=boiler}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name=boiler}
	},
	events = {
		[defines.events.on_tick] = onTick
	}
}
