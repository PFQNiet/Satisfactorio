local foundation = "foundation"
local tile = "stone-path"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == foundation then
		-- add tiles underneath this
		local tiles = {}
		for dx=-1.5,1.5,1 do
			for dy=-1.5,1.5,1 do
				table.insert(tiles,{name=tile,position={entity.position.x+dx,entity.position.y+dy}})
			end
		end
		entity.surface.set_tiles(tiles, true, false, false, true)
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == foundation then
		-- remove the tiles and restore their hidden_tile
		local tiles = {}
		for dx=-1.5,1.5,1 do
			for dy=-1.5,1.5,1 do
				local tile = entity.surface.get_hidden_tile({entity.position.x+dx,entity.position.y+dy})
				table.insert(tiles,{name=tile,position={entity.position.x+dx,entity.position.y+dy}})
			end
		end
		entity.surface.set_tiles(tiles, true, false, false, true)
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved
	}
}
