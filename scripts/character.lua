local healing_per_tick = 0.05
local max_health_healing = 30

local function onTick(event)
    local healing_per_tick = healing_per_tick
    local max_health_healing = max_health_healing
    local health = global['character-health']
    if health and #health > 0 then
        local players = game.players
        for pidx, _ in pairs(health) do
            local character = players[pidx].character
            if not character.in_combat then
                players[pidx].character.health = players[pidx].character.health + healing_per_tick
            end

            if character.health >= max_health_healing  then
                health[pidx] = nil
            end
        end
    end
end

local function onDamaged(event)
    local entity = event.entity
    if not (entity and entity.valid and entity.type == "character") then return end
    if entity.health >= max_health_healing then return end

    local health = global['character-health']
    if not health then
        global['character-health'] = {}
        health = global['character-health']
    end
    if not health[entity.player.index] then health[entity.player.index] = 1 end
end

local function onRespawned(event)
    local player = game.players[event.player_index]
	local character = player.character
	if character then
		character.health = 30
	end
end

return {
    events = {
        [defines.events.on_tick] = onTick,
        [defines.events.on_entity_damaged] = onDamaged,
        [defines.events.on_player_respawned] = onRespawned
    }
}