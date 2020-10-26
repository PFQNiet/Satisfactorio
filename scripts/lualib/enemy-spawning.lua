-- uses global['unit-groups'] to track ... unit groups. {spawn, group}

local function spawnGroup(surface,position,value)
	-- TODO use "value" to determine size of threat
	-- for now just spawn 4 biters at each point of interest
	local group = surface.create_unit_group{position=position,force="enemy"}
	for i=1,4 do
		local pos = surface.find_non_colliding_position("big-biter", position, 10, 0.1)
		if pos then
			group.add_member(surface.create_entity{
				name = "big-biter",
				position = pos,
				force = game.forces.enemy
			})
		end
	end
	if #group.members > 0 then
		if not global['unit-groups'] then global['unit-groups'] = {} end
		global['unit-groups'][group.group_number] = {
			spawn = position,
			group = group
		}
	end
	-- TODO sometimes spawn gas cloud entities
end
local function onCommandCompleted(event)
	local group = global['unit-groups'] and global['unit-groups'][event.unit_number]
	if group then
		-- by default, go to spawn point and 
		group.group.set_command{
			type = defines.command.compound,
			structure_type = defines.compound_command.return_last,
			commands = {
				{
					type = defines.command.go_to_location,
					destination = group.spawn,
					radius = 10
				},
				{
					type = defines.command.wander,
					radius = 20,
					ticks_to_wait = 900
				}
			}
		}
	end
end

return {
	spawnGroup = spawnGroup,
	lib = {
		events = {
			[defines.events.on_ai_command_completed] = onCommandCompleted
		}
	}
}
