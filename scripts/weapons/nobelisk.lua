-- uses global['nobelisk-queue'] to track a player's thrown Nobelisks
-- uses global['nobelisk-explosions'] to track tick => {entity, offset, force} where entity is either the on-ground, or the thing a sticker is stuck to

local detonator = "nobelisk-detonator"
local manualEffect = "nobelisk-explodable"
local nukeEffect = "nobelisk-nukable"

---@class NobeliskNames
---@field name string
---@field sticker string
---@field onground string
---@field detonation string
---@field cooldown number

---@type NobeliskNames[]
local nobelisks = {}
for _,name in pairs({"nobelisk","gas-nobelisk","pulse-nobelisk","cluster-nobelisk","nuke-nobelisk"}) do
	nobelisks[name] = {
		name = name,
		sticker = name.."-armed",
		onground = name.."-on-ground",
		detonation = name.."-detonation",
		cooldown = 12
	}
end
nobelisks['pulse-nobelisk'].cooldown = 24
nobelisks['gas-nobelisk'].cooldown = 30
nobelisks['cluster-nobelisk'].cooldown = 48
nobelisks['nuke-nobelisk'].cooldown = 240

---@class ExplosionData
---@field name string Name of the Nobelisk thrown
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
	local playerIndex = event.source_entity and event.source_entity.valid and event.source_entity.type == "character" and event.source_entity.player and event.source_entity.player.index or 0
	if nobelisks[event.effect_id] then
		-- a nobelisk projectile hit a potential target; stick it if possible, or drop on ground at this position
		local names = nobelisks[event.effect_id]
		local target = event.target_entity
		local offset
		if target and (target.type == "unit" or target.type == "character" or target.type == "car") then
			game.surfaces[event.surface_index].create_entity{
				name = names.sticker,
				position = event.target_position,
				force = event.source_entity and event.source_entity.force or "player",
				target = event.target_entity
			}
			offset = {
				target.position.x - event.target_position.x,
				target.position.y - event.target_position.y
			}
		else
			target = game.surfaces[event.surface_index].create_entity{
				name = names.onground,
				position = event.target_position,
				force = event.source_entity and event.source_entity.force or "player"
			}
			target.destructible = false
			offset = {0,0}
		end
		if not script_data.queue[playerIndex] then script_data.queue[playerIndex] = {} end
		table.insert(script_data.queue[playerIndex], {
			name = names.name,
			entity = target,
			surface = target.surface,
			offset = offset,
			force = event.source_entity and event.source_entity.force or "player"
		})
	end
	if event.effect_id == detonator then
		-- transfer player's queued nobelisks into the explosion queue
		local queue = script_data.queue[playerIndex]
		if queue then
			local tick = event.tick + 18
			for _,exp in pairs(queue) do
				if not script_data.explosions[tick] then script_data.explosions[tick] = {} end
				table.insert(script_data.explosions[tick], exp)
				tick = tick + (nobelisks[exp.name] and nobelisks[exp.name].cooldown or 12)
			end
			(playerIndex > 0 and game.players[playerIndex] or game).play_sound{path="nobelisk-detonator"}
			script_data.queue[playerIndex] = {}
		end
	end
	if event.effect_id == manualEffect then
		-- an entity that is normally indestructible has been exploded!
		local force = event.source_entity and event.source_entity.valid and event.source_entity.force or game.forces.neutral
		local target = event.target_entity
		if not (target and target.valid) then return end
		target.destructible = true
		if target.type == "container" then
			-- spill contents so you don't accidentally do something dumb like put the HUB Parts in wreckage and blow them up...
			local inventory = target.get_output_inventory()
			for i=1,#inventory do
				local stack = inventory[i]
				if stack.valid_for_read then
					target.surface.spill_item_stack(target.position, stack, true, force, false)
				end
			end
		end
		if target.is_entity_with_health then
			target.die(force)
		else
			target.destroy()
		end
	end
	if event.effect_id == nukeEffect then
		-- gas emitters can be nuked!
		local force = event.source_entity and event.source_entity.valid and event.source_entity.force or game.forces.neutral
		local target = event.target_entity
		if not (target and target.valid) then return end
		target.destructible = true
		if target.is_entity_with_health then
			target.die(force)
		else
			target.destroy()
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
						name = nobelisks[exp.name].onground,
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
	if script_data.explosions[event.tick] then
		for _,explosion in pairs(script_data.explosions[event.tick]) do
			local names = nobelisks[explosion.name] or "nobelisk"
			local pos = explosion.offset
			if explosion.entity and explosion.entity.valid then
				pos[1] = pos[1] + explosion.entity.position.x
				pos[2] = pos[2] + explosion.entity.position.y
			end
			explosion.surface.create_entity{
				name = names.detonation,
				position = pos,
				force = explosion.force,
				target = pos,
				speed = 1
			}
			if explosion.entity.valid then
				if explosion.entity.name == names.onground then
					explosion.entity.destroy()
				else
					-- if entity survived and nobody else has stickied it, remove its sticker
					local clean = true
					for _,q in pairs(script_data.queue) do
						for _,e in pairs(q) do
							if e.name == names.name and e.entity and e.entity.valid and e.entity == explosion.entity then
								clean = false
								break
							end
						end
						if not clean then break end
					end
					if clean then
						for _,s in pairs(explosion.entity.stickers) do
							if s.name == names.sticker then
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
