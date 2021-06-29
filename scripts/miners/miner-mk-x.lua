local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local fastTransfer = require(modpath.."scripts.organisation.containers").fastTransfer
local link = require(modpath.."scripts.lualib.linked-entity")

local miners = {
	["miner-mk-1"] = true,
	["miner-mk-2"] = true,
	["miner-mk-3"] = true
}
local box = "miner-box"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	local name = entity.name
	if miners[name] then
		-- spawn a box for this drill
		local store = entity.surface.create_entity{
			name = box,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		link.register(entity,store)

		io.addConnection(entity, {0,-6}, "output", store)
		entity.rotatable = false
	end
end

local function onFastTransfer(event, half)
	local player = game.players[event.player_index]
	local target = player.selected
	if not (target and target.valid) then return end
	if not miners[target.name] then return end
	local store = target.surface.find_entity(box, target.position)
	if not store then return end

	if player.cursor_stack.valid_for_read then
		-- allow placing resources into the drill only if it matches the resource node
		local resource = target.surface.find_entities_filtered{type="resource", position=target.position}[1]
		local rname = resource.prototype.mineable_properties.products[1].name
		if player.cursor_stack.name == rname then
			-- attempt to place in fuel box
			return fastTransfer(player, store, half)
		end
		player.surface.create_entity{
			name = "flying-text",
			position = {target.position.x, target.position.y - 0.5},
			text = {"inventory-restriction.cant-insert-into-restricted-slot", game.item_prototypes[rname].localised_name, player.cursor_stack.prototype.localised_name},
			render_player_index = player.index
		}
		player.play_sound{
			path = "utility/cannot_build"
		}
	else
		-- retrieve items from box
		fastTransfer(player, store, half)
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	events = {
		["fast-entity-transfer-hook"] = function(event) onFastTransfer(event, false) end,
		["fast-entity-split-hook"] = function(event) onFastTransfer(event, true) end
	}
}
