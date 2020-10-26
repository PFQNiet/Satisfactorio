-- uses global['nobelisk-queue'] to track a player's thrown Nobelisks
-- uses global['nobelisk-explosions'] to track tick => {entity, offset, force} where entity is either the on-ground, or the thing a sticker is stuck to

local name = "nobelisk"
local detonator = "nobelisk-detonator"
local sticker = name.."-armed"
local onground = name.."-on-ground"

local function onScriptTriggerEffect(event)
	local source = event.source_entity and event.source_entity.player and event.source_entity.player.index or 0
	if event.effect_id == name then
		local target
		if event.target_entity and (event.target_entity.type == "unit" or event.target_entity.type == "character" or event.target_entity.type == "car") then
			target = event.target_entity
			game.surfaces[event.surface_index].create_entity{
				name = sticker,
				position = event.target_position,
				force = event.source_entity and event.source_entity.force or "player",
				target = event.target_entity
			}
			offset = {
				event.target_entity.position.x - event.target_position.x,
				event.target_entity.position.y - event.target_position.y
			}
		else
			target = game.surfaces[event.surface_index].create_entity{
				name = onground,
				position = event.target_position,
				force = event.source_entity and event.source_entity.force or "player"
			}
			target.destructible = false
			offset = {0,0}
		end
		if not global['nobelisk-queue'] then global['nobelisk-queue'] = {} end
		if not global['nobelisk-queue'][source] then global['nobelisk-queue'][source] = {} end
		table.insert(global['nobelisk-queue'][source], {
			entity = target,
			offset = offset,
			force = event.source_entity and event.source_entity.force or "player"
		})
	end
	if event.effect_id == detonator then
		-- transfer player's queued nobelisks into the explosion queue
		local queue = global['nobelisk-queue'] and global['nobelisk-queue'][source]
		if queue then
			if not global['nobelisk-explosions'] then global['nobelisk-explosions'] = {} end
			for i,exp in pairs(queue) do
				local tick = event.tick + 18 + i*12
				if not global['nobelisk-explosions'][tick] then global['nobelisk-explosions'][tick] = {} end
				table.insert(global['nobelisk-explosions'][tick], exp)
			end
			(source > 0 and game.players[source] or game).play_sound{path="nobelisk-detonator"}
			global['nobelisk-queue'][source] = {}
		end
	end
end
local function onEntityDied(event)
	if global['nobelisk-explosions'] then
		for tick,explosions in pairs(global['nobelisk-explosions']) do
			for _,exp in pairs(explosions) do
				if exp.entity == event.entity then
					-- drop nobelisk on the ground instead
					exp.entity = event.entity.surface.create_entity{
						name = onground,
						position = event.entity.position,
						force = exp.force
					}
					exp.entity.destructible = false
				end
			end
		end
	end
end
local function onTick(event)
	if global['nobelisk-explosions'] and global['nobelisk-explosions'][event.tick] then
		for _,explosion in pairs(global['nobelisk-explosions'][event.tick]) do
			local pos = explosion.offset
			if explosion.entity and explosion.entity.valid then
				pos[1] = pos[1] + explosion.entity.position.x
				pos[2] = pos[2] + explosion.entity.position.y
			end
			explosion.entity.surface.create_entity{
				name = "big-explosion",
				position = pos
			}
			explosion.entity.surface.create_entity{
				name = "medium-scorchmark-tintable",
				position = pos
			}
			-- find nearby entities-with-health and damage them according to distance from the centre
			local entities = explosion.entity.surface.find_entities_filtered{
				position = pos,
				radius = 7
			}
			for _,entity in pairs(entities) do
				if entity.valid and entity.is_entity_with_health and entity.destructible then
					local dx = entity.position.x - pos[1]
					local dy = entity.position.y - pos[2]
					local damage = math.max(1,50-(dx*dx+dy*dy))
					entity.damage(damage, explosion.force, "explosion")
				end
				if entity.valid and entity.type == "cliff" then
					local dx = entity.position.x - pos[1]
					local dy = entity.position.y - pos[2]
					if dx*dx+dy*dy < 4*4 then
						entity.destroy{do_cliff_correction=true}
					end
				end
			end
			if explosion.entity.valid then
				if explosion.entity.name == onground then
					explosion.entity.destroy()
				else
					-- if entity survived and nobody else has stickied it, remove its sticker
					local clean = true
					for _,q in pairs(global['nobelisk-queue']) do
						if q.target and q.target.valid and q.target == explosion.entity then
							clean = false
							break
						end
					end
					if clean then
						for _,s in pairs(explosion.entity.stickers) do
							if s.name == sticker then
								s.destroy()
							end
						end
					end
				end
			end
		end
		global['nobelisk-explosions'][event.tick] = nil
	end
end

return {
	events = {
		[defines.events.on_script_trigger_effect] = onScriptTriggerEffect,
		[defines.events.on_tick] = onTick,
		[defines.events.on_entity_died] = onEntityDied
	}
}
