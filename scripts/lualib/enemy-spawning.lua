-- uses global['unit-tracking'] to track units unit_number = {spawn, entity}

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
local function spawnGroup(surface,position,value)
	-- TODO use "value" to determine size of threat
	-- for now just spawn 4 biters at each point of interest
	if not global['unit-tracking'] then global['unit-tracking'] = {} end
	for i=1,4 do
		local pos = surface.find_non_colliding_position("big-biter", position, 10, 0.1)
		if pos then
			local entity = surface.create_entity{
				name = "big-biter",
				position = pos,
				force = game.forces.enemy
			}
			local struct = {
				spawn = position,
				entity = entity
			}
			global['unit-tracking'][entity.unit_number] = struct
			_guardSpawn(struct)
		end
	end
	-- TODO sometimes spawn gas cloud entities
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
