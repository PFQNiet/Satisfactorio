-- uses global.unit_tracking to track units unit_number = {spawn, entity}
local math2d = require("math2d")

local spawndata = {
	[1] = {["fluffy-tailed-hog"] = 1},
	[2] = {["spitter"] = 1},
	[3] = {["alpha-hog"] = 0.75, ["fluffy-tailed-hog"] = 1.25},
	[4] = {["alpha-spitter"] = 0.75, ["spitter"] = 1.25},
	[5] = {["alpha-hog"] = 1, ["fluffy-tailed-hog"] = 2},
	[6] = {["alpha-spitter"] = 1, ["spitter"] = 2}
}

---@class UnitTracker
---@field id uint
---@field spawn Position
---@field entity LuaEntity

---@type UnitTracker[][]
local script_data = {}
local buckets = 60
for i=0,buckets-1 do script_data[i] = {} end
---@param tick uint
---@return UnitTracker[]
local function getBucket(tick)
	return script_data[tick%buckets]
end
local function registerStruct(id, struct)
	script_data[id%buckets][id] = struct
end
local function unregisterStruct(id)
	script_data[id%buckets][id] = nil
end
local function getStruct(id)
	local struct = script_data[id%buckets][id]
	if struct and not struct.entity.valid then
		unregisterStruct(id)
		return nil
	end
	return struct
end

local function _guardSpawn(struct)
	struct.entity.set_command{
		type = defines.command.compound,
		structure_type = defines.compound_command.return_last,
		commands = {
			{
				type = defines.command.go_to_location,
				distraction = defines.distraction.by_damage,
				destination = struct.spawn,
				radius = 10
			},
			{
				type = defines.command.wander,
				radius = 15
			}
		}
	}
end

local function getRandomOffset(position)
	local r = (math.random()*100)^0.5
	local theta = math.random()*math.pi*2
	return {position[1]+math.cos(theta)*r, position[2]-math.sin(theta)*r}
end

local function spawnGroup(surface,position,value,basedist)
	local settings = game.default_map_gen_settings.autoplace_controls["enemy-base"] or {frequency=1,richness=1,size=1}
	if settings.size == 0 then return end
	-- size = strength, frequency = number
	local saferange = 240 * game.default_map_gen_settings.starting_area

	-- scale value based on distance from spawn
	local random = math.random
	local realdist = math.sqrt(position[1]*position[1] + position[2]*position[2])
	local distance = math.ceil(realdist/basedist + 0.5)
	-- sometimes shift up or down a tier
	if random()<0.25 then
		value = value - 1
	elseif random()<0.25 then
		value = value + 1
	end
	value = math.min(6,math.max(1,math.floor(value*settings.size+0.5))) -- minimum setting always yields 1, maximum setting always yields 6
	if realdist < saferange then
		-- early spawns should be super easy since you only have the Xeno-Zapper
		value = 1
		if realdist < saferange/2 and random()<0.5 then
			-- *very* early spawns may even be undefended
			return
		end
	elseif realdist < saferange*2 then
		-- prevent Alphas from spawning within 2x the starting area
		value = math.min(value, 2)
	elseif realdist < saferange*4 then
		-- prevent big groups within 4x the starting area
		value = math.min(value, 4)
	end

	for name,count in pairs(spawndata[value]) do
		count = count*(distance^(1/3)) * settings.frequency
		if random()<count%1 then count = math.ceil(count) else count = math.floor(count) end
		if realdist < saferange then count = 1 end
		for i=1,count do
			local offset = getRandomOffset(position)
			local pos = surface.find_non_colliding_position(name, offset, 10, 0.1)
			if pos then
				local entity = surface.create_entity{
					name = name,
					position = pos,
					force = game.forces.enemy
				}
				local struct = {
					id = entity.unit_number,
					spawn = position,
					entity = entity
				}
				registerStruct(entity.unit_number, struct)
				_guardSpawn(struct)
			else
				surface.create_entity{
					name = "flying-crab-hatcher",
					position = offset,
					force = game.forces.enemy
				}
			end
		end
	end
	if realdist > saferange and random()<math.min(10,value*distance)/20 then
		-- add some gas clouds
		local name
		if game.default_map_gen_settings.autoplace_controls['x-deposit'].size > 0 then
			name = random() < 0.85 and "spore-flower" or "gas-emitter"
		else
			name = "spore-flower" -- don't allow Behemoth Worms (indestructible) if resource deposits are turned off - TODO make it a separate option
		end
		for i=1,4 do
			-- find_non_colliding_position doesn't support the map gen box, which is needed for worm turrets to give ore nodes some space
			for _=1,10 do
				local pos = getRandomOffset(position)
				if not surface.entity_prototype_collides(name, pos, true) then
					surface.create_entity{
						name = name,
						position = pos,
						force = game.forces.enemy,
						raise_built = true
					}.destructible = false
					break
				end
			end
		end
	end
	-- and very rarely some uranium deposits
	if value*distance > 5 and random() < 0.02 then
		for i=1,4 do
			local pos = surface.find_non_colliding_position("rock-big-uranium-ore", getRandomOffset(position), 10, 0.1)
			if pos then
				surface.create_entity{
					name = "rock-big-uranium-ore",
					position = pos,
					force = game.forces.neutral
				}
			end
		end
	end
end
---@param event on_ai_command_completed
local function onCommandCompleted(event)
	local struct = getStruct(event.unit_number)
	if struct then
		_guardSpawn(struct)
	end
end
-- after attacking a player, check if we went too far from spawn and return there if so
local function onDamaged(event)
	if not (event.entity and event.entity.valid) then return end
	if event.entity.type == "character" and event.cause and event.cause.valid and event.cause.type == "unit" then
		local struct = getStruct(event.cause.unit_number)
		if struct then
			local distance_from_home = math2d.position.distance(struct.entity.position, struct.spawn)
			if distance_from_home > 50 then
				_guardSpawn(struct)
			end
		end
	end
end
-- periodically check if unit has strayed too far (chasing the player) and go back to spawn if so
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
		if not struct.entity.valid then
			unregisterStruct(struct.id)
		else
			local distance_from_home = math2d.position.distance(struct.entity.position, struct.spawn)
			if distance_from_home > 50 then
				_guardSpawn(struct)
			end
		end
	end
end
local function onEntityDied(event)
	if event.entity.valid and event.entity.unit_number then
		unregisterStruct(event.entity.unit_number)
	end
end

return {
	spawnGroup = spawnGroup,
	lib = {
		on_init = function()
			global.unit_tracking = global.unit_tracking or script_data
		end,
		on_load = function()
			script_data = global.unit_tracking or script_data
		end,
		events = {
			[defines.events.on_tick] = onTick,
			[defines.events.on_entity_died] = onEntityDied,
			[defines.events.on_entity_damaged] = onDamaged,
			[defines.events.on_ai_command_completed] = onCommandCompleted
		}
	}
}
