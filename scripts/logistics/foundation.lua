local bev = require(modpath.."scripts.lualib.build-events")
local math2d = require("math2d")

local foundation = "foundation"
local tile = "stone-path"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == foundation then
		-- look for foundations to snap to
		for _,dir in pairs({defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west}) do
			local vector = math2d.position.rotate_vector({0,-4}, dir*45)
			local target = math2d.position.add(entity.position, vector)
			local snapto = entity.surface.find_entity(foundation, target)
			if snapto then
				-- if the position matches the expected position (to within an epsilon due to rotation and floats...) then we're good
				if math2d.position.distance_squared(target, snapto.position) > 0.1 then
					-- figure out where to snap to
					local snapped = math2d.position.subtract(snapto.position, vector)
					entity.teleport(snapped)
				end
				-- else position matches so we're already snapped to a foundation
				break
			end
		end

		-- add tiles underneath
		local tiles = {}
		for dx=-1.5,1.5,1 do
			for dy=-1.5,1.5,1 do
				table.insert(tiles,{name=tile,position={entity.position.x+dx,entity.position.y+dy}})
			end
		end
		entity.surface.set_tiles(tiles, true, false, true, true)

		local fish = entity.surface.find_entities_filtered{area=entity.selection_box, type="fish"}
		for _,f in pairs(fish) do
			f.destroy()
		end

		entity.minable = false
	else
		-- if the building is placed on foundation, then prevent that foundation from being deconstructed if it's marked that way
		local foundations = entity.surface.find_entities_filtered{area=entity.bounding_box, name=foundation}
		for _,f in pairs(foundations) do
			f.cancel_deconstruction(f.force)
			f.minable = false
		end
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == foundation then
		-- remove the tiles and restore their hidden_tile
		local tiles = {}
		for dx=-1.5,1.5,1 do
			for dy=-1.5,1.5,1 do
				local original_tile = entity.surface.get_hidden_tile({entity.position.x+dx,entity.position.y+dy})
				table.insert(tiles,{name=original_tile,position={entity.position.x+dx,entity.position.y+dy}})
			end
		end
		entity.surface.set_tiles(tiles, true, false, false, true)
		local others = entity.surface.find_entities_filtered{area=entity.selection_box, name=foundation, invert=true}
		for _,other in pairs(others) do
			-- this should only happen if an entity has moved here, eg. character or enemy
			-- if the entity collides with the tile it's on, then it probably drowned
			local new_tile = other.surface.get_tile(other.position)
			for layer,_ in pairs(game.entity_prototypes[other.name].collision_mask) do
				if new_tile.collides_with(layer) then
					-- found a collision!
					other.die()
					break
				end
			end
		end
	end
end

---@param event on_player_selected_area
local function onSelectedArea(event)
	if event.item == "deconstruct-foundation" then
		local player = game.players[event.player_index]
		local blocked = 0
		for _,f in pairs(event.entities) do
			if f.force == player.force then
				if f.surface.count_entities_filtered{
					area = f.selection_box,
					invert = true, -- any of the following are fine...
					force = "neutral",
					name = {foundation,"nobelisk-on-ground"},
					type = "smoke-with-trigger"
				} == 0 then
					f.minable = true
					f.order_deconstruction(player.force, player)
				else
					blocked = blocked + 1
				end
			end
		end
		if blocked > 0 then
			player.print{"message.foundation-blocked",blocked}
		end
	end
end
---@param event on_player_alt_selected_area
local function onDeselectedArea(event)
	if event.item == "deconstruct-foundation" then
		local player = game.players[event.player_index]
		for _,f in pairs(event.entities) do
			f.cancel_deconstruction(player.force, player)
			f.minable = false
		end
	end
end
---@param event on_marked_for_deconstruction
local function onDeconstruct(event)
	if event.entity.type == "deconstructible-tile-proxy" then
		event.entity.cancel_deconstruction(event.entity.force, event.player_index and game.players[event.player_index] or nil)
	end
end
---@param event on_cancelled_deconstruction
local function onUndoDeconstruct(event)
	if event.entity.name == foundation then
		event.entity.minable = false
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_player_selected_area] = onSelectedArea,
		[defines.events.on_player_alt_selected_area] = onDeselectedArea,
		[defines.events.on_marked_for_deconstruction] = onDeconstruct,
		[defines.events.on_cancelled_deconstruction] = onUndoDeconstruct
	}
}
