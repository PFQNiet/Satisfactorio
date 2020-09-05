local mod_gui = require("mod-gui")
local util = require("util")

local hub = "the-hub"
local terminal = "the-hub-terminal"
local bench = "craft-bench"
local storage = "wooden-chest"
local graphics = {
	[defines.direction.north] = hub.."-north",
	[defines.direction.east] = hub.."-east",
	[defines.direction.south] = hub.."-south",
	[defines.direction.west] = hub.."-west"
}

local milestones = require("scripts/milestones")

local function retrieveItemsFromCraftBench(bench, target)
	-- collect items from the Craft Bench inventories (input, output, modules, and craft-in-progress if any) and place them in target event buffer
	local inventories = {
		defines.inventory.assembling_machine_input,
		defines.inventory.assembling_machine_output,
		defines.inventory.assembling_machine_modules
	}
	for _, k in ipairs(inventories) do
		local source = bench.get_inventory(k)
		for i = 1, #source do
			local stack = source[i]
			if stack.valid and stack.valid_for_read then
				target.insert(stack)
			end
		end
	end
	if bench.is_crafting() then
		-- a craft was left in progress, get the ingredients and give those back too
		local recipe = bench.get_recipe()
		for i = 1, #recipe.ingredients do
			target.insert(recipe.ingredients[i])
		end
	end
end
local function retrieveItemsFromStorage(box, target)
	-- collect items from the Personal Storage inventory and place them in target event buffer
	local source = bench.get_inventory(defines.inventory.chest)
	for i = 1, #source do
		local stack = source[i]
		if stack.valid and stack.valid_for_read then
			target.insert(stack)
		end
	end
end

local rotations = {
	[defines.direction.north] = {0,-1},
	[defines.direction.east] = {1,0},
	[defines.direction.south] = {0,1},
	[defines.direction.west] = {-1,0}
}
local function position(relative,to)
	local rot1 = rotations[to.direction]
	local rot2 = rotations[(to.direction+2)%8]
	local rel = {relative[1] or relative.x or 0, relative[2] or relative.y or 0}
	local pos = {to.position[1] or to.position.x or 0, to.position[2] or to.position.y or 0}
	return {
		pos[1] + rel[1]*rot1[1] + rel[2]*rot2[1],
		pos[2] + rel[1]*rot1[2] + rel[2]*rot2[2]
	}
end
local bench_pos = {0,2.5}
local bench_rotation = 2 -- 90deg
local storage_pos = {-3,0}

local function buildFloor(hub)
	return hub.surface.create_entity{
		name = graphics[hub.direction],
		position = hub.position,
		force = hub.force,
		raise_built = true
	}
end
local function buildTerminal(hub)
	local terminal = hub.surface.create_entity{
		name = terminal,
		position = hub.position,
		direction = hub.direction,
		force = hub.force,
		raise_built = true
	}
	terminal.active = false -- "crafting" is faked :D
	global['hub-terminal'][terminal.force.name] = {terminal.surface.name, terminal.position}
	return terminal
end
local function buildCraftBench(hub)
	local craft = hub.surface.create_entity{
		name = bench,
		position = position(bench_pos,hub),
		direction = (hub.direction+bench_rotation)%8,
		force = hub.force,
		raise_built = true
	}
	craft.minable = false
	return craft
end
local function buildStorageChest(hub)
	local box = hub.surface.create_entity{
		name = storage,
		position = position(storage_pos,hub),
		force = hub.force,
		raise_built = true
	}
	box.minable = false
	return box
end

local function updateMilestoneGUI()
	local cache = {}
	for _,player in pairs(game.players) do
		if not cache[player.force.name] then
			local submitted = nil
			local hub = global['hub-terminal'][player.force.name]
			local term = nil
			local recipe = nil
			local milestone = nil
			local ingredients = nil
			if hub then
				term = game.get_surface(hub[1]).find_entity(terminal,hub[2])
				if term and term.valid then
					recipe = term.get_recipe()
					if recipe then
						local inventory = term.get_inventory(defines.inventory.assembling_machine_input)
						submitted = inventory.get_contents()
						milestone = game.item_prototypes[recipe.products[1].name]
						ingredients = {}
						for _,ingredient in ipairs(recipe.ingredients) do
							ingredients[ingredient.name] = {
								item = game.item_prototypes[ingredient.name],
								amount = ingredient.amount
							}
							if submitted[ingredient.name] and submitted[ingredient.name] > ingredient.amount then
								-- remove excess...
								term.surface.spill_item_stack(
									term.position,
									{
										name = ingredient.name,
										count = inventory.remove{
											name = ingredient.name,
											count = submitted[ingredient.name] - ingredient.amount
										},
									},
									true,
									term.force,
									false
								)
								submitted[ingredient.name] = ingredient.amount
							end
						end
					end
				end
			end
			if not recipe then
				cache[player.force.name] = {valid=false}
			else
				cache[player.force.name] = {
					valid = true,
					submitted = submitted,
					recipe = recipe,
					milestone = milestone,
					ingredients = ingredients
				}
			end
		end

		local gui = mod_gui.get_frame_flow(player)
		local frame = gui['hub-milestone-tracking']
		local data = cache[player.force.name]
		if not data.valid then
			if frame then frame.destroy() end
		else
			if not frame then
				frame = gui.add{
					type="frame",
					name="hub-milestone-tracking",
					direction="vertical",
					caption={"gui.hub-milestone-tracking-caption"},
					style=mod_gui.frame_style
				}
				frame.style.use_header_filler = false
			end
			frame.clear()
			frame.add{type="label", caption={"","[item="..data.milestone.name.."] [font=default-semibold]",data.milestone.localised_name,"[/font]"}}
			local inner = frame.add{type = "frame", style = "inside_shallow_frame", direction = "vertical"}
			inner.style.horizontally_stretchable = true
			local table = inner.add{
				type = "table",
				style = "bordered_table",
				column_count = 3
			}
			for key,ingredient in pairs(data.ingredients) do
				local sprite = table.add{type="sprite-button", sprite="item/"..ingredient.item.name, style="transparent_slot"}
				sprite.style.height = 20
				sprite.style.width = 20
				table.add{type="label", caption=ingredient.item.localised_name, style="bold_label"}
				local count_flow = table.add{type="flow"}
				local pusher = count_flow.add{type="empty-widget"}
				pusher.style.horizontally_stretchable = true
				count_flow.add{type="label", caption={"gui.fraction", util.format_number(data.submitted[key] or 0), ingredient.amount}}
			end
		end
	end
end

local function removeCraftBench(hub, buffer)
	local craft = hub.surface.find_entity(bench,position(bench_pos,hub))
	if not craft or not craft.valid then
		game.print("Couldn't find the craft bench")
		return
	end
	if buffer then
		retrieveItemsFromCraftBench(craft, buffer)
	end
	craft.destroy()
end

local function removeStorageChest(hub, buffer) -- only if it exists
	local box = hub.surface.find_entity(storage,position(storage_pos,hub))
	if box and box.valid then
		if buffer then retrieveItemsFromStorage(box, buffer) end
		box.destroy()
	end
end

local function removeGraphic(hub)
	-- identify the graphic that was used here
	local graphic = graphics[hub.direction] -- later this will include graphics for different stages of Tier 0
	local dec = hub.surface.find_entity(graphic,hub.position)
	if not dec or not dec.valid then
		game.print("Couldn't find the graphic")
		return
	end
	dec.destroy()
end

return {
	name = hub,
	terminal = terminal,
	bench = bench,
	storage = storage,
	graphics = graphics,
	buildFloor = buildFloor,
	buildTerminal = buildTerminal,
	buildCraftBench = buildCraftBench,
	buildStorageChest = buildStorageChest,
	retrieveItemsFromCraftBench = retrieveItemsFromCraftBench,
	retrieveItemsFromStorage = retrieveItemsFromStorage,
	updateMilestoneGUI = updateMilestoneGUI,
	removeGraphic = removeGraphic,
	removeCraftBench = removeCraftBench,
	removeStorageChest = removeStorageChest
}
