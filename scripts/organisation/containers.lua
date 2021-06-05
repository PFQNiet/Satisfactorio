-- uses global.containers to track structures {combinator, storage} for updating
local script_data = {}
for i=0,59 do script_data[i] = {} end
local function register(combinator, storage)
	script_data[combinator.unit_number%60][combinator.unit_number] = {
		combinator = combinator,
		container = storage
	}
end
local function getRegistration(entity)
	return script_data[entity.unit_number%60][entity.unit_number]
end

-- fast-transfer items to or from the target entity, returns whether items were actually moved
local function fastTransfer(player, target, half)
	if not player.can_reach_entity(target) then
		player.surface.create_entity{
			name = "flying-text",
			position = {target.position.x, target.position.y - 0.5},
			text = {"cant-reach"},
			render_player_index = player.index
		}
		player.play_sound{
			path = "utility/cannot_build"
		}
		return false
	end
	if player.cursor_stack.valid_for_read then
		-- player is holding an item => insert it into the container
		local name = player.cursor_stack.name
		local inserted = half and target.insert{name=name,count=math.ceil(player.cursor_stack.count/2)} or target.insert(player.cursor_stack)
		if inserted == player.cursor_stack.count then
			player.cursor_stack.clear()
		else
			player.cursor_stack.count = player.cursor_stack.count - inserted
		end
		if inserted > 0 then
			player.play_sound{ path = "utility/inventory_move" }
			player.surface.create_entity{
				name = "flying-text",
				position = {target.position.x, target.position.y - 0.5},
				text = {"", -inserted, " ", game.item_prototypes[name].localised_name, " (", player.get_item_count(name), ")"},
				render_player_index = player.index
			}
			if not player.cursor_stack.valid_for_read then
				-- check if player has more of the item in their inventory and grab them if so
				local inventory = player.get_main_inventory()
				local stack, index = inventory.find_item_stack(name)
				if stack then
					if player.cursor_stack.transfer_stack(stack) then
						player.hand_location = {inventory=player.get_main_inventory().index, slot=index}
					end
				end
			end
		end
		return inserted > 0
	else
		-- player is NOT holding an item => retrieve as many items as possible from the container
		local retrieved = {}
		local inventory = target.get_inventory(defines.inventory.chest)
		for i=1,#inventory do
			local stack = inventory[i]
			if stack.valid_for_read then
				local name = stack.name
				local inserted = half and player.insert{name=name,count=math.ceil(stack.count/2)} or player.insert(stack)
				if inserted == stack.count then
					stack.clear()
				else
					stack.count = stack.count - inserted
				end
				retrieved[name] = (retrieved[name] or 0) + inserted
			end
		end
		local line_number = 0
		for name,count in pairs(retrieved) do
			if line_number == 0 then
				player.play_sound{ path = "utility/inventory_move" }
			end
			player.surface.create_entity{
				name = "flying-text",
				position = {target.position.x, target.position.y - 0.5 + 0.5*line_number},
				text = {"", "+", count, " ", game.item_prototypes[name].localised_name, " (", player.get_item_count(name), ")"},
				render_player_index = player.index
			}
			line_number = line_number + 1
		end
		return line_number > 0
	end
end

local function updateSignals(data)
	-- get contents and update combinator
	local contents = data.container.get_inventory(defines.inventory.chest).get_contents()
	local signals = {}
	for item,count in pairs(contents) do
		table.insert(signals, {
			index = #signals+1,
			signal = {type="item",name=item},
			count = count
		})
	end
	data.combinator.get_or_create_control_behavior().parameters = signals
end
local function onTick(event)
	local mod = event.tick%60
	for id,data in pairs(script_data[mod]) do
		if not (data.container.valid and data.combinator.valid) then
			-- unregister invalid entity
			script_data[mod][id] = nil
		else
			updateSignals(data)
		end
	end
end

local function onFastTransfer(event, half)
	local player = game.players[event.player_index]
	local data = player.selected and player.selected.valid and getRegistration(player.selected)
	if not data then return end
	fastTransfer(player, data.container, half)
	updateSignals(data)
end

return {
	on_init = function()
		global.containers = global.containers or script_data
	end,
	on_load = function()
		script_data = global.containers or script_data
	end,
	on_configuration_changed = function()
		if not global.containers then global.containers = script_data end
	end,
	events = {
		[defines.events.on_tick] = onTick,
		["fast-entity-transfer-hook"] = function(event) onFastTransfer(event, false) end,
		["fast-entity-split-hook"] = function(event) onFastTransfer(event, true) end
	},

	register = register,
	fastTransfer = fastTransfer
}
