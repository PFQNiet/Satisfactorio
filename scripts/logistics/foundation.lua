local bm = require(modpath.."scripts.lualib.building-management")
local bev = require(modpath.."scripts.lualib.build-events")
local math2d = require("math2d")

local foundation = "foundation"
local deconstruct = "deconstructible-foundation-proxy"
local tile = "stone-path"

---@param entity LuaEntity
local function onBuilt(entity)
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
end

---@param entity LuaEntity
---@param buffer LuaInventory
---@param player LuaPlayer
local function onRemoved(entity, buffer, player)
	if entity.name == deconstruct then
		local floor = entity.surface.find_entity(foundation, entity.position)
		if floor then
			if floor.surface.count_entities_filtered{
				area = floor.selection_box,
				invert = true, -- any of the following are fine...
				force = "neutral",
				name = {foundation,"nobelisk-on-ground"},
				type = "smoke-with-trigger"
			} == 0 then
				floor.destroy{raise_destroy = true}
			else
				-- blocked by entity, create new deconstruction proxy
				floor.surface.create_entity{
					name = deconstruct,
					position = floor.position
				}
				-- to avoid reliance on event order, try removing the Foundation from the buffer and then remove its ingredients if it failed
				for _,p in pairs(entity.prototype.mineable_properties.products) do
					if buffer.remove{name=p.name, count=p.amount} == 0 then
						local recipe = bm.getBuildingRecipe(p.name)
						for _,i in pairs(recipe.ingredients) do
							buffer.remove{name=i.name, count=i.amount}
						end
					end
				end
				if player then
					player.create_local_flying_text{
						text = {"message.foundation-blocked"},
						create_at_cursor = true
					}
				end
			end
		end
	end
	if entity.name == foundation then
		-- remove the tiles and restore their hidden_tile
		local tiles = {}
		for dx=-1.5,1.5,1 do
			for dy=-1.5,1.5,1 do
				local original_tile = entity.surface.get_hidden_tile({entity.position.x+dx,entity.position.y+dy})
				if original_tile then
					table.insert(tiles,{name=original_tile,position={entity.position.x+dx,entity.position.y+dy}})
				end
			end
		end
		if #tiles > 0 then
			entity.surface.set_tiles(tiles, true, false, false, true)
		end
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
		for _,f in pairs(event.entities) do
			if f.force == player.force then
				player.surface.create_entity{
					name = deconstruct,
					position = f.position
				}
			end
		end
	end
end

---@param event on_player_alt_selected_area
local function onDeselectedArea(event)
	if event.item == "deconstruct-foundation" then
		local player = game.players[event.player_index]
		for _,f in pairs(event.entities) do
			local floor = f.surface.find_entity(foundation, f.position)
			if floor.force == player.force then f.destroy() end
		end
	end
end

-- prevent marking tiles for deconstruction
---@param event on_marked_for_deconstruction
local function onDeconstruct(event)
	if event.entity.type == "deconstructible-tile-proxy" then
		event.entity.cancel_deconstruction(event.entity.force, event.player_index and game.players[event.player_index] or nil)
	end
end

local function onPipette(event)
	local player = game.players[event.player_index]
	if player.selected then return end
	if not player.is_cursor_empty() then return end
	if player.surface.find_entity(foundation, event.cursor_position) then
		player.cursor_ghost = foundation
		player.play_sound{path="utility/smart_pipette"}
	end
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=foundation}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name={foundation, deconstruct}}
	},
	events = {
		[defines.events.on_player_selected_area] = onSelectedArea,
		[defines.events.on_player_alt_selected_area] = onDeselectedArea,
		[defines.events.on_marked_for_deconstruction] = onDeconstruct,
		["pipette-foundation"] = onPipette
	}
}
