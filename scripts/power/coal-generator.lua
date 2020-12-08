local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local math2d = require("math2d")
local powertrip = require(modpath.."scripts.lualib.power-trip")

local base = "coal-generator"
local boiler = "coal-generator-boiler"
local boiler_pos = {0,4}
local generator_ne = "coal-generator-generator-ne"
local generator_sw = "coal-generator-generator-sw"
local generator = {
	[defines.direction.north] = generator_ne,
	[defines.direction.east] = generator_ne,
	[defines.direction.south] = generator_sw,
	[defines.direction.west] = generator_sw
}
local generator_pos = {0,-2}
local accumulator = {
	[defines.direction.north] = "coal-generator-accumulator-ns",
	[defines.direction.east] = "coal-generator-accumulator-ew",
	[defines.direction.south] = "coal-generator-accumulator-ns",
	[defines.direction.west] = "coal-generator-accumulator-ew"
}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		-- spawn boiler and generator
		local boil = entity.surface.create_entity{
			name = boiler,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(boiler_pos, entity.direction*45)),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		local gen = entity.surface.create_entity{
			name = generator[entity.direction],
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(generator_pos, entity.direction*45)),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		io.addInput(entity, {1,5.5}, boil)
		powertrip.registerGenerator(boil, gen, accumulator[entity.direction])
		-- make the base intangible (TODO: remove the base outright and put graphics on the child entities instead)
		entity.operable = false
		entity.rotatable = false
		gen.rotatable = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == base or entity.name == boiler or entity.name == generator_ne or entity.name == generator_sw then
		-- find the base that should be right here
		local floor = entity.surface.find_entity(base,entity.position)
		if not floor or not floor.valid then
			game.print("Couldn't find the floor")
			return
		end
		local boil = entity.surface.find_entity(boiler, math2d.position.add(floor.position, math2d.position.rotate_vector(boiler_pos, floor.direction*45)))
		local gen = entity.surface.find_entity(generator[entity.direction], math2d.position.add(floor.position, math2d.position.rotate_vector(generator_pos, floor.direction*45)))
		powertrip.unregisterGenerator(boil)
		if entity.name ~= boiler then
			-- safely get items from the boiler
			getitems.burner(boil, event and event.buffer or nil)
			boil.destroy()
		end
		if entity.name ~= generator_ne and entity.name ~= generator_sw then
			gen.destroy()
		end
		io.remove(floor, event)
		floor.destroy()
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved
	}
}
