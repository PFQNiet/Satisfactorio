-- uses global['unit-tracking'] to track units unit_number = {spawn, entity}
local math2d = require("math2d")

local spawndata = {
	[1] = {["big-biter"] = 1},
	[2] = {["big-spitter"] = 1},
	[3] = {["behemoth-biter"] = 0.75, ["big-biter"] = 1.25},
	[4] = {["behemoth-spitter"] = 0.75, ["big-spitter"] = 1.25},
	[5] = {["behemoth-biter"] = 1, ["big-biter"] = 2},
	[6] = {["behemoth-spitter"] = 1, ["big-spitter"] = 2}
}

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

	-- scale value based on distance from spawn
	local realdist = math.sqrt(position[1]*position[1] + position[2]*position[2])
	local distance = math.ceil(realdist/basedist + 0.5)
	-- sometimes shift up or down a tier
	if math.random()<0.25 then
		value = value - 1
	elseif math.random()<0.25 then
		value = value + 1
	end
	value = math.min(6,math.max(1,math.floor(value*settings.size+0.5))) -- minimum setting always yields 1, maximum setting always yields 6
	if realdist < 240 then
		-- early spawns should be super easy since you only have the Xeno-Basher
		value = 1
	end

	if not global['unit-tracking'] then global['unit-tracking'] = {} end
	for name,count in pairs(spawndata[value]) do
		count = count*(distance^(1/3)) * settings.frequency
		if math.random()<count%1 then count = math.ceil(count) else count = math.floor(count) end
		if realdist < 240 then count = math.min(2,count) end
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
					spawn = position,
					entity = entity
				}
				global['unit-tracking'][entity.unit_number] = struct
				_guardSpawn(struct)
			else
				surface.create_entity{
					name = "small-worm-turret", -- flying crab spawner
					position = offset,
					force = game.forces.enemy
				}
			end
		end
	end
	if realdist > 240 and math.random()<math.min(10,value*distance)/20 then
		-- add some gas clouds
		local name = math.random() < 0.85 and "big-worm-turret" or "behemoth-worm-turret"
		for i=1,4 do
			-- find_non_collising_position doesn't support the map gen box, which is needed for worm turrets to give ore nodes some space
			for _=1,10 do
				local pos = getRandomOffset(position)
				if not surface.entity_prototype_collides(name, pos, true) then
					surface.create_entity{
						name = name,
						position = pos,
						force = game.forces.enemy
					}.destructible = false
					break
				end
			end
		end
	end
	-- and very rarely some uranium deposits
	if value*distance > 5 and math.random() < 0.02 then
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
local function onCommandCompleted(event)
	local struct = global['unit-tracking'] and global['unit-tracking'][event.unit_number]
	if struct then
		if struct.entity.valid then
			_guardSpawn(struct)
		else
			-- died perhaps, clean up the struct
			global['unit-tracking'][event.unit_number] = nil
		end
	end
end
-- after attacking a player, check if we went too far from spawn and return there if so
local function onDamaged(event)
	if event.entity.type == "character" and event.cause and event.cause.valid and event.cause.type == "unit" then
		local struct = global['unit-tracking'] and global['unit-tracking'][event.cause.unit_number]
		if struct then
			local distance_from_home = math2d.position.distance(struct.entity.position, struct.spawn)
			if distance_from_home > 50 then
				_guardSpawn(struct)
			end
		end
	end
end
local function onEntityDied(event)
	if event.entity.valid and event.entity.unit_number and global['unit-tracking'] and global['unit-tracking'][event.entity.unit_number] then
		global['unit-tracking'][event.entity.unit_number] = nil
	end
end

return {
	spawnGroup = spawnGroup,
	lib = {
		events = {
			[defines.events.on_entity_died] = onEntityDied,
			[defines.events.on_entity_damaged] = onDamaged,
			[defines.events.on_ai_command_completed] = onCommandCompleted
		}
	}
}
