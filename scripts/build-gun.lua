-- uses global.rail_freebies to give 5 free rails for every rail paid for
-- this effectively reduces the cost of rails to 1/6
local script_data = {} -- dictionary of player index to number of free rails granted

local function canAfford(player, materials, inventory, buffer)
	if player.cheat_mode then return 100 end
	local contents = inventory.get_contents()
	if buffer then buffer = buffer.get_contents() else buffer = {} end
	local affordable = math.huge
	for _,product in pairs(materials) do
		local got = (contents[product.name] or 0) + (buffer[product.name] or 0)
		if got < product.amount then
			return 0
		end
		affordable = math.min(affordable, math.floor(got / product.amount))
	end
	return affordable
end
local function getUndoRecipe(name)
	if not name then return nil end
	local test = game.recipe_prototypes[name.."-undo"]
	if test then return test end
	-- try looking up the entity
	local prototype = game.entity_prototypes[name]
	if not prototype then return nil end
	local place = prototype.items_to_place_this
	if not place then return nil end
	for _,item in pairs(place) do
		test = game.recipe_prototypes[item.name.."-undo"]
		if test then return test end
	end
end

local function refundEntity(player, entity)
	-- if the entity has an undo recipe, refund the components instead
	if not (player and player.cheat_mode) then
		local undo = getUndoRecipe(entity.name)
		local insert = undo and undo.products or {{name=entity.name,amount=1}}
		for _,refund in pairs(insert) do
			local spill = refund.amount
			if player then spill = spill - player.insert{name=refund.name,count=refund.amount} end
			if spill > 0 then
				(player or entity).surface.spill_item_stack(
					(player or entity).position,
					{name = refund.name, count = spill},
					true, player and player.force or nil, false
				)
			end
		end
	end
	entity.destroy{raise_destroy=true} -- allow IO to snap loader belts back
end

local function updateGUI(player, buffer)
	-- if an event buffer is passed, add its contents to the player's inventory for counting purposes
	local gui = player.gui.screen.buildgun
	if not gui then
		gui = player.gui.screen.add{
			type = "frame",
			name = "buildgun",
			direction = "vertical",
			ignored_by_interaction = true,
			style = "inner_frame_in_outer_frame"
		}
		gui.style.horizontally_stretchable = false
		gui.style.use_header_filler = false
		gui.style.width = 540
		local flow = gui.add{
			type = "flow",
			direction = "horizontal",
			name = "content"
		}
		flow.add{type="empty-widget"}.style.horizontally_stretchable = true
		flow.add{
			type = "flow",
			direction = "horizontal",
			name = "materials"
		}
		flow.add{type="empty-widget"}.style.horizontally_stretchable = true
	end
	gui.visible = false

	local name = (player.cursor_stack.valid_for_read and player.cursor_stack.name) or (player.cursor_ghost and player.cursor_ghost.name) or ""
	local undo = getUndoRecipe(name)
	if not undo then return end
	local inventory = player.get_main_inventory().get_contents()
	if buffer then buffer = buffer.get_contents() else buffer = {} end
	local cost = undo.products
	
	local item = game.item_prototypes[name]
	gui.caption = {"gui.build-gun-caption", name, item.localised_name}
	local list = gui.content.materials
	list.clear()
	local table = list.add{
		type = "table",
		column_count = #cost
	}
	table.style.left_cell_padding = 6
	table.style.right_cell_padding = 6
	for i,product in pairs(cost) do
		table.style.column_alignments[i] = "right"
		-- first row: icons
		local number = product.amount
		if item.type == "rail-planner" then
			if (script_data[player.index] or 0) > 0 then
				number = 0.1*script_data[player.index]
			end
		end
		local icon = table.add{
			type = "sprite-button",
			style = "transparent_slot",
			sprite = "item/"..product.name,
			number = number,
			tooltip = game.item_prototypes[product.name].localised_name
		}
		icon.style.width = 64
		icon.style.height = 64
	end
	for _,product in pairs(cost) do
		-- second row: progress bars
		local satisfaction = player.cheat_mode and product.amount or ((inventory[product.name] or 0) + (buffer[product.name] or 0))
		local bar = table.add{
			type = "progressbar",
			value = satisfaction / product.amount,
			style = "electric_satisfaction_statistics_progressbar",
			caption = player.cheat_mode and {"infinity"} or util.format_number(satisfaction)
		}
		bar.style.width = 64
	end

	gui.visible = true
	gui.location = {(player.display_resolution.width-460*player.display_scale)/2, player.display_resolution.height-300*player.display_scale}
end

local function onCraft(event)
	-- if the item to craft has an undo recipe, cancel the craft and put the item in the cursor
	local undo = getUndoRecipe(event.recipe.prototype.main_product.name)
	if undo then
		local player = game.players[event.player_index]
		-- find the craft in the queue - it should really be the only one under Satisfactorio rules but to be safe...
		local index = -1
		for i=1,player.crafting_queue_size do
			if player.crafting_queue[i].recipe == event.recipe.name then
				index = i
				break
			end
		end
		if index < 0 then
			player.print("Can't find the item in the crafting queue...")
		else
			player.cancel_crafting{index=index,count=event.queued_count}
			player.clear_cursor()
			local item = event.recipe.prototype.products[1].name
			player.cursor_stack.set_stack{name=item, count=game.item_prototypes[item].stack_size}
			if player.opened_self then player.opened = nil end
		end
	end
end
local function onCursorChange(event)
	-- also called on main inventory change
	-- also called from onRemoved to update affordability and re-put a real entity if you mined stuff to afford what you're holding, so event.buffer may exist
	-- if the player has no item in hand but does have a ghost, they may have pipetted or selected an entity from their hotbar
	-- if the ghost item has an undo recipe, the base recipe is enabled, and the player can afford it, swap the ghost for a real entity
	local player = game.players[event.player_index]
	updateGUI(player)
	if player.cursor_stack.valid_for_read then return end
	if not player.cursor_ghost then return end
	local name = player.cursor_ghost.name
	local redo = player.force.recipes[name]
	if not (redo and redo.enabled) then return end
	local undo = getUndoRecipe(name)
	if not undo then return end
	if canAfford(player, undo.products, player.get_main_inventory(), event.buffer) < 1 then return end
	player.clear_cursor()
	player.cursor_stack.set_stack{name=name, count=game.item_prototypes[name].stack_size}
	-- updateGUI(player)
end

local function onBuilt(event)
	local player = game.players[event.player_index]
	local entity = event.created_entity
	local name = entity.name
	-- if the item in the cursor is an undo-able building, check if the player has enough stuff (something else may have pulled items from the player's inventory)
	local undo = getUndoRecipe(name)
	if not undo then return end

	local inventory = player.get_main_inventory()
	local afford = canAfford(player, undo.products, inventory)
	if player.cursor_stack.valid_for_read and player.cursor_stack.type == "rail-planner" then
		afford = afford*6 + (script_data[player.index] or 0)
	end
	local source = undo.ingredients[1].name
	if afford < 1 then
		-- this shouldn't happen, but may if another player or script changes the player's inventory (eg. drones...)
		player.clear_cursor() -- cancel the build
		player.cursor_ghost = source
		player.create_local_flying_text{
			text = {"not-enough-ingredients"},
			create_at_cursor = true
		}
		player.play_sound{
			path = "utility/cannot_build"
		}
		entity.destroy()
		-- updateGUI(player)
		return
	end
	if not player.cheat_mode then
		local pay = true
		-- special case: if the built item is from a rail planner, reduce cost by 1/6
		if player.cursor_stack.valid_for_read and player.cursor_stack.type == "rail-planner" then
			local cost = entity.type == "curved-rail" and 4 or 1
			if (script_data[player.index] or 0) >= cost then pay = false end
			afford = afford - cost
			script_data[player.index] = afford % 6
		end
		if pay then
			-- items exist, now remove them
			for _,product in pairs(undo.products) do
				inventory.remove{name=product.name, count=product.amount}
			end
			afford = afford-1
		end
	end
	if afford > 0 then
		player.cursor_stack.set_stack{name=source,count=math.min(afford,game.item_prototypes[source].stack_size)}
	else
		player.cursor_ghost = source
	end
	updateGUI(player)
end

local function onRemoved(event)
	local player = event.player_index and game.players[event.player_index]
	local cheater = player and player.cheat_mode
	if event.buffer then
		for item,count in pairs(event.buffer.get_contents()) do
			-- if an undo recipe exists for this item, replace it with the undo results
			local undo = game.recipe_prototypes[item.."-undo"]
			if undo then
				event.buffer.remove{name=item, count=count}
				local proto = game.item_prototypes[item]
				local pay = true
				if proto.type == "rail-planner" then
					-- don't refund rails that weren't paid for
					local cost = event.entity.type == "curved-rail" and 4 or 1
					script_data[player.index] = (script_data[player.index] or 0) + cost
					pay = false
					if script_data[player.index] >= 6 then
						script_data[player.index] = script_data[player.index] % 6
						pay = true
					end
				end
				for _,product in pairs(undo.products) do
					if not cheater then
						if pay then
							-- undo recipes are always solids, and don't use probability stuff so fixed amounts
							event.buffer.insert{name=product.name, count=product.amount*count}
						end
					end
				end
			end
		end
	end
	onCursorChange(event)
end

return {
	on_init = function()
		global.rail_freebies = global.rail_freebies or script_data
	end,
	on_load = function()
		script_data = global.rail_freebies or script_data
	end,
	on_configuration_changed = function()
		if not global.rail_freebies then global.rail_freebies = script_data end
	end,
	events = {
		[defines.events.on_pre_player_crafted_item] = onCraft,
		[defines.events.on_player_cursor_stack_changed] = onCursorChange,
		[defines.events.on_player_main_inventory_changed] = onCursorChange,
		
		[defines.events.on_built_entity] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved
	},
	refundEntity = refundEntity
}
