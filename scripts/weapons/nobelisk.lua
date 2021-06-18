-- uses global['nobelisk-queue'] to track a player's thrown Nobelisks
-- uses global['nobelisk-explosions'] to track tick => {entity, offset, force} where entity is either the on-ground, or the thing a sticker is stuck to

local name = "nobelisk"
local detonator = "nobelisk-detonator"
local sticker = name.."-armed"
local onground = name.."-on-ground"

local script_data = {
	queue = {},
	explosions = {}
}

local function onScriptTriggerEffect(event)
	local source = event.source_entity and event.source_entity.type == "character" and event.source_entity.player and event.source_entity.player.index or 0
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
		if not script_data.queue[source] then script_data.queue[source] = {} end
		table.insert(script_data.queue[source], {
			entity = target,
			offset = offset,
			force = event.source_entity and event.source_entity.force or "player",
			cause = event.source_entity
		})
	end
	if event.effect_id == detonator then
		-- transfer player's queued nobelisks into the explosion queue
		local queue = script_data.queue[source]
		if queue then
			for i,exp in pairs(queue) do
				local tick = event.tick + 18 + i*12
				if not script_data.explosions[tick] then script_data.explosions[tick] = {} end
				table.insert(script_data.explosions[tick], exp)
			end
			(source > 0 and game.players[source] or game).play_sound{path="nobelisk-detonator"}
			script_data.queue[source] = {}
		end
	end
end
local function onEntityDied(event)
	for pid,explosions in pairs(script_data.explosions) do
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
local spaceship_wreckage = {
	["crash-site-spaceship"] = true,
	["crash-site-spaceship-wreck-big-1"] = true,
	["crash-site-spaceship-wreck-big-2"] = true,
	["crash-site-spaceship-wreck-medium-1"] = true,
	["crash-site-spaceship-wreck-medium-2"] = true,
	["crash-site-spaceship-wreck-medium-3"] = true,
	["crash-site-spaceship-wreck-small-1"] = true,
	["crash-site-spaceship-wreck-small-2"] = true,
	["crash-site-spaceship-wreck-small-3"] = true,
	["crash-site-spaceship-wreck-small-4"] = true,
	["crash-site-spaceship-wreck-small-5"] = true,
	["crash-site-spaceship-wreck-small-6"] = true
}
local function onTick(event)
	if script_data.explosions[event.tick] then
		for _,explosion in pairs(script_data.explosions[event.tick]) do
			local pos = explosion.offset
			if explosion.entity and explosion.entity.valid then
				pos[1] = pos[1] + explosion.entity.position.x
				pos[2] = pos[2] + explosion.entity.position.y
			end
			explosion.entity.surface.create_entity{
				name = "big-explosion",
				position = pos
			}
			if explosion.entity.surface.can_place_entity{
				name = "medium-scorchmark-tintable",
				position = pos
			} then explosion.entity.surface.create_entity{
				name = "medium-scorchmark-tintable",
				position = pos
			} end
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
					if entity.type == "tree" then damage = 100 end -- just wreck the trees
					entity.damage(damage, explosion.force, "explosion")
				end
				if entity.valid and entity.type == "cliff" then
					local dx = entity.position.x - pos[1]
					local dy = entity.position.y - pos[2]
					if dx*dx+dy*dy < 4*4 then
						entity.destroy{do_cliff_correction=true}
					end
				end
				if entity.valid and entity.name == "big-worm-turret" then
					local dx = entity.position.x - pos[1]
					local dy = entity.position.y - pos[2]
					if dx*dx+dy*dy < 6*6 then
						entity.destructible = true
						entity.die(explosion.force)
					end
				end
				if entity.valid and entity.name == "rock-huge" then
					local dx = entity.position.x - pos[1]
					local dy = entity.position.y - pos[2]
					if dx*dx+dy*dy < 6*6 then
						entity.destroy()
					end
				end
				if entity.valid and spaceship_wreckage[entity.name] then
					local dx = entity.position.x - pos[1]
					local dy = entity.position.y - pos[2]
					if dx*dx+dy*dy < 6*6 then
						entity.destructible = true
						if entity.is_entity_with_health then
							entity.die()
						else
							entity.destroy()
						end
					end
				end
			end
			if explosion.entity.valid then
				if explosion.entity.name == onground then
					explosion.entity.destroy()
				else
					-- if entity survived and nobody else has stickied it, remove its sticker
					local clean = true
					for _,q in pairs(script_data.queue) do
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
		script_data.explosions[event.tick] = nil
	end
end

return {
	on_init = function()
		global.nobelisk = global.nobelisk or script_data
	end,
	on_load = function()
		script_data = global.nobelisk or script_data
	end,
	events = {
		[defines.events.on_script_trigger_effect] = onScriptTriggerEffect,
		[defines.events.on_tick] = onTick,
		[defines.events.on_entity_died] = onEntityDied
	}
}
