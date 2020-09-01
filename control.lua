local function OnEntityCreated(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == "portable-miner-drill" then
		-- spawn a box for this drill
		local box = entity.surface.create_entity{
			name = "portable-miner",
			position = entity.position,
			force = entity.force
		}
		-- make the drill intangible
		entity.operable = false
		entity.minable = false
		entity.destructible = false
	end
end
local function OnEntityRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == "portable-miner" then
		-- find the drill that should be right here
		local drill = entity.surface.find_entity("portable-miner-drill",entity.position)
		if not drill or not drill.valid then
			game.print("Couldn't find the drill")
			return
		end
		drill.destroy()
	end
end
local function registerEvents()
	local portable_miner_filter = {{filter="name",name="portable-miner"}, {filter="name",name="portable-miner-drill"}}
	script.on_event( defines.events.on_built_entity, OnEntityCreated, portable_miner_filter )
	script.on_event( defines.events.on_robot_built_entity, OnEntityCreated, portable_miner_filter )
	script.on_event( {defines.events.script_raised_built, defines.events.script_raised_revive}, OnEntityCreated )

	script.on_event( defines.events.on_player_mined_entity, OnEntityRemoved, portable_miner_filter )
	script.on_event( defines.events.on_robot_mined_entity, OnEntityRemoved, portable_miner_filter )
	script.on_event( defines.events.on_entity_died, OnEntityRemoved, portable_miner_filter )
	script.on_event( defines.events.script_raised_destroy, OnEntityRemoved )
	log("Registered events!")
end

script.on_init(function(event)
	local resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","crude-oil","caterium-ore"}
	for i, res in ipairs(resources) do
		for dx = 0, 2 do
			for dy = 0, 2 do
				game.surfaces.nauvis.create_entity{
					name = res,
					position = {i*6+dx, -6+dy},
					force = game.forces.neutral,
					amount = 60
				}
				game.surfaces.nauvis.create_entity{
					name = res,
					position = {i*6+dx, 0+dy},
					force = game.forces.neutral,
					amount = 120
				}
				game.surfaces.nauvis.create_entity{
					name = res,
					position = {i*6+dx, 6+dy},
					force = game.forces.neutral,
					amount = 240
				}
			end
		end
	end

	registerEvents()
end)
script.on_load(function(event)
	registerEvents()
end)
