local name = "flying-crab"
local spawner = "small-worm-turret"
local spawn = "crab-spawn"
local impact = "crab-impact"

local function onScriptTriggerEffect(event)
	if event.effect_id == impact
	and event.source_entity and event.source_entity.valid and event.source_entity.name == name
	and event.target_entity and event.target_entity.valid then
		-- hit-and-run
		event.source_entity.set_command{
			type = defines.command.compound,
			structure_type = defines.compound_command.return_last,
			commands = {
				{
					type = defines.command.flee,
					from = event.target_entity,
					distraction = defines.distraction.none
				},
				{
					type = defines.command.wander,
					ticks_to_wait = 120
				}
			}
		}
	end
	if event.effect_id == spawn and event.source_entity and event.source_entity.valid and event.source_entity.name == spawner then
		-- self-destruct
		event.source_entity.surface.create_entity{
			name = "item-on-ground",
			force = "neutral",
			position = event.source_entity.position,
			stack = {name="alien-carapace",count=1}
		}
		event.source_entity.die(event.source_entity.force, event.source_entity)
	end
end
local function onEntityDied(event)
	if event.entity.name == spawner then
		for i=1,3 do
			local r = math.random()+1
			local theta = math.random()*math.pi*2
			local crab = event.entity.surface.create_entity{
				name = name,
				force = event.entity.force,
				position = {
					event.entity.position.x + math.cos(theta)*r,
					event.entity.position.y - math.sin(theta)*r
				}
			}
			crab.set_command{
				type = defines.command.go_to_location,
				destination = {
					event.entity.position.x + math.cos(theta)*r*5,
					event.entity.position.y - math.sin(theta)*r*5
				},
				distraction = defines.distraction.none,
				radius = 1
			}
		end
	end
end

return {
	events = {
		[defines.events.on_script_trigger_effect] = onScriptTriggerEffect,
		[defines.events.on_entity_died] = onEntityDied
	}
}
