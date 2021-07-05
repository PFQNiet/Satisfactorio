-- uses global['nobelisk-queue'] to track a player's thrown Nobelisks
-- uses global['nobelisk-explosions'] to track tick => {entity, offset, force} where entity is either the on-ground, or the thing a sticker is stuck to

local name = "nobelisk"
local detonator = "nobelisk-detonator"
local sticker = name.."-armed"
local onground = name.."-on-ground"

---@class ExplosionData
---@field entity LuaEntity Either the entity it is stuck to, or the nobelisk-on-ground entity
---@field surface LuaSurface
---@field offset Position When stuck to an entity, the offset determines where exactly it was stuck on the entity
---@field force ForceIdentification The force that will be blamed for the death of anything blown up

---@class global.nobelisk
---@field queue table<uint, ExplosionData[]> Map source player ID to placed Nobelisks
---@field explosions table<uint, ExplosionData[]> Map game tick on which to explode, to the exploding Nobelisks
local script_data = {
	queue = {},
	explosions = {}
}

---@param event on_script_trigger_effect
local function onScriptTriggerEffect(event)
	local source = event.source_entity and event.source_entity.type == "character" and event.source_entity.player and event.source_entity.player.index or 0
	if event.effect_id == name then
		local target, offset
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
			surface = target.surface,
			offset = offset,
			force = event.source_entity and event.source_entity.force or "player"
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
	for _,group in pairs({script_data.queue, script_data.explosions}) do
		for _,explosions in pairs(group) do
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
-- dictionary of entity names that are part of explodable spaceship wreckage
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
-- target is in range of an explosion, do something!
---@param target LuaEntity
---@param dist2 number Distance^2 from the centre of the explosion
---@param force LuaForce The force that owns the explosion
local function processExplosion(target, dist2, force)
	if target.is_entity_with_health and target.destructible then
		local damage = math.max(1, 50 - dist2)
		if target.type == "tree" then damage = 100 end
		target.damage(damage, force, "explosion")
		return
	end
	if target.type == "cliff" then
		-- smaller explosion radius
		if dist2 < 4*4 then
			target.destroy{do_cliff_correction = true}
		end
		return
	end
	if target.name == "spore-flower" or (target.name == "gas-emitter" and target.health < 5) then
		-- slightly smaller explosion radius
		if dist2 < 6*6 then
			-- override destructibility to kill the entity
			target.destructible = true
			target.die(force)
		end
		return
	end
	if target.name == "rock-huge" then
		-- slightly smaller explosion radius
		if dist2 < 6*6 then
			target.destroy()
		end
		return
	end
	if spaceship_wreckage[target.name] then
		-- slightly smaller explosion radius
		if dist2 < 6*6 then
			target.destructible = true
			if target.is_entity_with_health then
				target.die(force)
			else
				target.destroy()
			end
		end
		return
	end
end

local function onTick(event)
	if script_data.explosions[event.tick] then
		for _,explosion in pairs(script_data.explosions[event.tick]) do
			local pos = explosion.offset
			if explosion.entity and explosion.entity.valid then
				pos[1] = pos[1] + explosion.entity.position.x
				pos[2] = pos[2] + explosion.entity.position.y
			end
			explosion.surface.create_entity{
				name = "big-explosion",
				position = pos
			}
			if explosion.surface.can_place_entity{
				name = "medium-scorchmark-tintable",
				position = pos
			} then explosion.surface.create_entity{
				name = "medium-scorchmark-tintable",
				position = pos
			} end
			-- find nearby entities-with-health and damage them according to distance from the centre
			local entities = explosion.surface.find_entities_filtered{
				position = pos,
				radius = 7
			}
			for _,entity in pairs(entities) do
				if entity.valid then
					local tpos = entity.position
					local dx = tpos.x - pos[1]
					local dy = tpos.y - pos[2]
					local distance_squared = dx*dx+dy*dy
					processExplosion(entity, distance_squared, explosion.force)
				end
			end
			if explosion.entity.valid then
				if explosion.entity.name == onground then
					explosion.entity.destroy()
				else
					-- if entity survived and nobody else has stickied it, remove its sticker
					local clean = true
					for _,q in pairs(script_data.queue) do
						for _,e in pairs(q) do
							if e.entity and e.entity.valid and e.entity == explosion.entity then
								clean = false
								break
							end
						end
						if not clean then break end
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
