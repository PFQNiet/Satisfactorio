local name = "flying-crab"
local spawner = "flying-crab-hatcher"
local spawn = "crab-spawn"
local impact = "crab-impact"

---@param event on_script_trigger_effect
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
		local entity = event.source_entity
		local position = entity.position
		-- spawn crabs
		for _=1,3 do
			local r = math.random()+1
			local theta = math.random()*math.pi*2
			local crab = entity.surface.create_entity{
				name = name,
				force = entity.force,
				position = {
					position.x + math.cos(theta)*r,
					position.y - math.sin(theta)*r
				}
			}
			crab.set_command{
				type = defines.command.go_to_location,
				destination = {
					position.x + math.cos(theta)*r*5,
					position.y - math.sin(theta)*r*5
				},
				distraction = defines.distraction.none,
				radius = 1
			}
		end
	end
end

-- Manually place carapace here rather than using loot system, because loot system uses collision and these are mostly on water
---@param event on_entity_died
local function onEntityDied(event)
	if event.entity.name == spawner then
		event.entity.surface.create_entity{
			name = "item-on-ground",
			force = "neutral",
			position = event.entity.position,
			stack = {name="hatcher-remains",count=1}
		}
	end
end

return {
	events = {
		[defines.events.on_script_trigger_effect] = onScriptTriggerEffect,
		[defines.events.on_entity_died] = onEntityDied
	}
}
