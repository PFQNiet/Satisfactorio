-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors
local debounce_error = {}

local refundEntity = require(modpath.."scripts.build-gun").refundEntity

-- prevent placement of transport belts if it would lead to a belt having more than one input
local function isValidBelt(entity)
	-- ensure this entity, and its output neighbour, have fewer than 2 input neighbours
	local neighbours = entity.belt_neighbours
	if #neighbours.inputs > 1 then return false end
	local out = neighbours.outputs[1]
	if out and #out.belt_neighbours.inputs > 1 then return false end
	return true
end

local belts = {
	["transport-belt"] = true,
	["fast-transport-belt"] = true,
	["express-transport-belt"] = true,
	["turbo-transport-belt"] = true,
	["ultimate-transport-belt"] = true,
	["underground-belt"] = true,
	["fast-underground-belt"] = true,
	["express-underground-belt"] = true,
	["turbo-underground-belt"] = true,
	["ultimate-underground-belt"] = true
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
			return
		end
	end
end
local function onRotated(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if belts[entity.name] then
		if not isValidBelt(entity) then
			if event.entity.type == "underground-belt" then
				event.entity.rotate()
			else
				event.entity.direction = event.previous_direction
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

return {
	on_init = function()
		global.debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_rotated_entity] = onRotated
	}
}
