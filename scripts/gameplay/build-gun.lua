-- uses global.rail_freebies to give 5 free rails for every rail paid for
-- this effectively reduces the cost of rails to 1/6
local script_data = {} -- dictionary of player index to number of free rails granted

local bm = require(modpath.."scripts.lualib.building-management")

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

local function updateGUI(player, buffer)
	-- if an event buffer is passed, add its contents to the player's inventory for counting purposes
	local gui = player.gui.screen.buildgun
	if not gui then
		gui = player.gui.screen.add{
			type = "frame",
			name = "buildgun",
			direction = "vertical",
			ignored_by_interaction = true,
			style = "blurry_frame"
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
	local recipe = bm.getBuildingRecipe(name)
	if not recipe then return end
	local inventory = player.get_main_inventory().get_contents()
	if buffer then buffer = buffer.get_contents() else buffer = {} end
	local cost = recipe.ingredients

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
	gui.location = {(player.display_resolution.width-540*player.display_scale)/2, player.display_resolution.height-300*player.display_scale}
end

local function onCraft(event)
	-- if the item to craft has an undo recipe, cancel the craft and put the item in the cursor
	local recipe = bm.getBuildingRecipe(event.recipe.prototype.main_product.name)
	if recipe then
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
			local affordable = canAfford(player, recipe.ingredients, player.get_main_inventory())
			player.cursor_stack.set_stack{name=item, count=math.min(affordable,game.item_prototypes[item].stack_size)}
			if player.opened_self then player.opened = nil end
		end
	end
end
---@param event on_player_crafted_item
local function onCheatCraft(event)
	local recipe = bm.getBuildingRecipe(event.recipe.prototype.main_product.name)
	if recipe then
		local player = game.players[event.player_index]
		player.clear_cursor()
		event.item_stack.clear()
		local item = event.recipe.prototype.products[1].name
		player.cursor_stack.set_stack{name=item, count=game.item_prototypes[item].stack_size}
		if player.opened_self then player.opened = nil end
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
	local recipe = bm.getBuildingRecipe(name)
	if not recipe then return end
	local affordable = canAfford(player, recipe.ingredients, player.get_main_inventory(), event.buffer)
	if affordable < 1 then return end
	player.clear_cursor()
	player.cursor_stack.set_stack{name=name, count=math.min(affordable,game.item_prototypes[name].stack_size)}
	-- updateGUI(player)
end

local function onBuilt(event)
	local player = game.players[event.player_index]
	local entity = event.created_entity
	local name = entity.name
	-- if the item in the cursor is an undo-able building, check if the player has enough stuff (something else may have pulled items from the player's inventory)
	local recipe = bm.getBuildingRecipe(name)
	if not recipe then return end

	local inventory = player.get_main_inventory()
	local afford = canAfford(player, recipe.ingredients, inventory)
	if player.cursor_stack.valid_for_read and player.cursor_stack.type == "rail-planner" then
		afford = afford*6 + (script_data[player.index] or 0)
	end
	local source = recipe.main_product.name
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
			for _,product in pairs(recipe.ingredients) do
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
			-- if a building recipe exists for this item, replace it with the ingredients
			local recipe = bm.getBuildingRecipe(item)
			if recipe then
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
						count = 1 -- only refund one of the rails
					end
				end
				if pay and not cheater then
					for _,product in pairs(recipe.ingredients) do
						-- building recipes are always solids
						event.buffer.insert{name=product.name, count=product.amount*count}
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
	events = {
		[defines.events.on_pre_player_crafted_item] = onCraft,
		[defines.events.on_player_crafted_item] = onCheatCraft,
		[defines.events.on_player_cursor_stack_changed] = onCursorChange,
		[defines.events.on_player_main_inventory_changed] = onCursorChange,

		[defines.events.on_built_entity] = onBuilt, -- manual player build ONLY

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved
	}
}
