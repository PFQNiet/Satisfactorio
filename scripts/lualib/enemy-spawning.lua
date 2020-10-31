-- uses global['unit-tracking'] to track units unit_number = {spawn, entity}

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
	local r = (math.random()*3)^2
	local theta = math.random()*math.pi*2
	return {position[1]+math.cos(theta)*r, position[2]-math.sin(theta)*r}
end
local function spawnGroup(surface,position,value,basedist)
	-- scale value based on distance from spawn
	local distance = math.ceil(math.sqrt(position[1]*position[1] + position[2]*position[2])/basedist + 0.5)
	-- sometimes shift up or down a tier
	if value > 1 and math.random()<0.25 then
		value = value - 1
	elseif value < 6 and math.random()<0.25 then
		value = value + 1
	end

	if not global['unit-tracking'] then global['unit-tracking'] = {} end
	for name,count in pairs(spawndata[value]) do
		count = count*(distance^(1/3))
		if math.random()<count%1 then count = math.ceil(count) else count = math.floor(count) end
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
	if math.random()<math.min(10,value*distance)/20 then
		-- add some gas clouds
		local name = math.random() < 0.85 and "big-worm-turret" or "behemoth-worm-turret"
		local offset = getRandomOffset(position)
		local pos = surface.find_non_colliding_position(name, offset, 4, 0.25, false)
		if pos then
			surface.create_entity{
				name = name,
				position = pos,
				force = game.forces.enemy
			}
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
local function onEntityDied(event)
	if event.entity.unit_number and global['unit-tracking'] and global['unit-tracking'][event.entity.unit_number] then
		global['unit-tracking'][event.entity.unit_number] = nil
	end
end

return {
	spawnGroup = spawnGroup,
	lib = {
		events = {
			[defines.events.on_entity_died] = onEntityDied,
			[defines.events.on_ai_command_completed] = onCommandCompleted
		}
	}
}
