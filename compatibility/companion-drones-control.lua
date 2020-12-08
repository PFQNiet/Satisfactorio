local paytable = require(modpath.."constants.sink-tradein")

local function setup()
	if script.active_mods['Companion_Drones'] then
		-- allow discarding into the Awesome Sink
		paytable['companion'] = 1000
	end
end

local function onBuilt(event)
	local entity = event.created_entity
	if not entity or not entity.valid then return end
	if entity.name ~= "companion" then return end

	local player = event.player_index and game.players[event.player_index]
	if not player then return end
	
	local grid = entity.grid
	grid.clear()
	grid.put{name="companion-reactor-equipment"}
	grid.put{name="companion-roboport-equipment",by_player=player} -- just trigger player_placed_equipment once.
end

return {
	on_init = setup,
	on_load = setup,
	events = {
		[defines.events.on_built_entity] = onBuilt -- only built manually by player
	}
}
