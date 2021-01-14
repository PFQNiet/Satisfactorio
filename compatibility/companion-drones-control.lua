error("Satisfactorio is no longer compatible with Companion Drones")

if not script.active_mods['Companion_Drones'] then return {} end
local paytable = require(modpath.."constants.sink-tradein")

local function setup()
	-- allow discarding into the Awesome Sink
	paytable['companion'] = 1000
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

local function onSecond(event)
	for _,surface in pairs(game.surfaces) do
		for _,drone in pairs(surface.find_entities_filtered{name="companion"}) do
			drone.health = drone.health + 1
		end
	end
end

local function onDied(event)
	if event.entity.name == "companion" then
		-- drop fuel and inventory as "loot"
		local fuel = event.entity.get_inventory(defines.inventory.fuel)
		for k,v in pairs(fuel.get_contents()) do
			event.loot.insert{name=k,count=v}
		end
		local content = event.entity.get_inventory(defines.inventory.spider_trunk)
		for k,v in pairs(content.get_contents()) do
			event.loot.insert{name=k,count=v}
		end
	end
end

return {
	on_init = setup,
	on_load = setup,
	on_nth_tick = {
		[60] = onSecond
	},
	events = {
		[defines.events.on_built_entity] = onBuilt, -- only built manually by player
		[defines.events.on_entity_died] = onDied
	}
}
