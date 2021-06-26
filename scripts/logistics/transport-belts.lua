-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors
local debounce_error = {}

local bev = require(modpath.."scripts.lualib.build-events")
local refundEntity = require(modpath.."scripts.lualib.building-management").refundEntity

-- prevent placement of transport belts if it would lead to a belt having more than one input
local function isValidBelt(entity)
	-- ensure this entity, and its output neighbour, have fewer than 2 input neighbours
	local neighbours = entity.belt_neighbours
	local max_allowed = (entity.type == "underground-belt" and entity.belt_to_ground_type == "output") and 0 or 1
	if #neighbours.inputs > max_allowed then return false end
	local out = neighbours.outputs[1]
	if not out then return true end
	max_allowed = (out.type == "underground-belt" and out.belt_to_ground_type == "output") and 0 or 1
	if #out.belt_neighbours.inputs > max_allowed then return false end
	return true
end

local belts = {
	["conveyor-belt-mk-1"] = true,
	["conveyor-belt-mk-2"] = true,
	["conveyor-belt-mk-3"] = true,
	["conveyor-belt-mk-4"] = true,
	["conveyor-belt-mk-5"] = true,
	["conveyor-lift-mk-1"] = true,
	["conveyor-lift-mk-2"] = true,
	["conveyor-lift-mk-3"] = true,
	["conveyor-lift-mk-4"] = true,
	["conveyor-lift-mk-5"] = true
}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if belts[entity.name] then
		if not isValidBelt(entity) then
			local player = entity.last_user
			refundEntity(player, entity)
			if not debounce_error[player.force.index] or debounce_error[player.force.index] < event.tick then
				player.create_local_flying_text{
					text = {"message.belt-no-naked-merging"},
					create_at_cursor = true
				}
				player.play_sound{
					path = "utility/cannot_build"
				}
				debounce_error[player.force.index] = event.tick + 60
			end
		end
	end
end
local function onRotated(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if belts[entity.name] then
		if not isValidBelt(entity) or (entity.type == "underground-belt" and entity.neighbours and not isValidBelt(entity.neighbours)) then
			if entity.type == "underground-belt" then
				entity.rotate()
			else
				entity.direction = event.previous_direction
			end
			local player = game.players[event.player_index]
			player.create_local_flying_text{
				text = {"message.belt-no-naked-merging"},
				create_at_cursor = true
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_build = onBuilt,
	events = {
		[defines.events.on_player_rotated_entity] = onRotated
	}
}
