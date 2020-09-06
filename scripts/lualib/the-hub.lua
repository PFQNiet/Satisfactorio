-- uses global['hub-terminal'] as table of Force name -> {surface, position} of the HUB terminal
-- uses global['hub-milestones'] as table of Force name -> milestone[]

local mod_gui = require("mod-gui")
local util = require("util")
local string = require("scripts.lualib.string")
local omnilab = require("scripts.lualib.omnilab")

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

local function findHubForForce(force)
	local pos = global['hub-terminal'] and global['hub-terminal'][force.name] or nil
	if not pos then return nil end
	return game.get_surface(pos[1]).find_entity(terminal,pos[2])
end
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
				if target then
					target.insert(stack)
				else
					bench.surface.spill_item_stack(bench.position, stack, true, bench.force, false)
				end
			end
		end
	end
	if bench.is_crafting() then
		-- a craft was left in progress, get the ingredients and give those back too
		local recipe = bench.get_recipe()
		for i = 1, #recipe.ingredients do
			if target then
				target.insert(recipe.ingredients[i])
			else
				bench.surface.spill_item_stack(bench.position, recipe.ingredients[i], true, bench.force, false)
			end
		end
	end
end
local function retrieveItemsFromStorage(box, target)
	-- collect items from the Personal Storage inventory and place them in target event buffer
	local source = box.get_inventory(defines.inventory.chest)
	for i = 1, #source do
		local stack = source[i]
		if stack.valid and stack.valid_for_read then
			if target then
				target.insert(stack)
			else
				box.surface.spill_item_stack(box.position, stack, true, box.force, false)
			end
		end
	end
end

local rotations = {
	[defines.direction.north] = {0,-1},
	[defines.direction.east] = {1,0},
	[defines.direction.south] = {0,1},
	[defines.direction.west] = {-1,0}
}
local function position(relative,to) -- relative is {forward, rightward} based on to.direction
	local rot1 = rotations[to.direction]
	local rot2 = rotations[(to.direction+2)%8]
	local rel = {relative[1] or relative.x or 0, relative[2] or relative.y or 0}
	local pos = {to.position[1] or to.position.x or 0, to.position[2] or to.position.y or 0}
	return {
		pos[1] + rel[1]*rot1[1] + rel[2]*rot2[1],
		pos[2] + rel[1]*rot1[2] + rel[2]*rot2[2]
	}
end
local spawn_pos = {0,1}
local bench_pos = {0,2.5}
local bench_rotation = 2 -- 90deg
local storage_pos = {-2,0}

local function buildFloor(hub)
	-- also build the Omnilab (which will check if this is the first time the HUB is being placed)
	omnilab.setupOmnilab(hub.force)
	return hub.surface.create_entity{
		name = graphics[hub.direction],
		position = hub.position,
		force = hub.force,
		raise_built = true
	}
end
local function removeFloor(hub)
	-- identify the graphic that was used here
	local graphic = graphics[hub.direction] -- later this will include graphics for different stages of Tier 0
	local dec = hub.surface.find_entity(graphic,hub.position)
	if not dec or not dec.valid then
		game.print("Couldn't find the graphic")
		return
	end
	dec.destroy()
	-- remove terminal entity from global list
	global['hub-terminal'][hub.force.name] = nil
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
	if not global['hub-terminal'] then global['hub-terminal'] = {} end
	global['hub-terminal'][terminal.force.name] = {terminal.surface.name, terminal.position}
	hub.force.set_spawn_position(position(spawn_pos,hub), hub.surface)
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

local function buildStorageChest(hub)
	-- only if HUB Upgrade 1 is done
	if not (global['hub-milestones'] and global['hub-milestones'][hub.force.name] and global['hub-milestones'][hub.force.name]['hub-tier0-hub-upgrade-1']) then
		return
	end
	local box = hub.surface.create_entity{
		name = storage,
		position = position(storage_pos,hub),
		force = hub.force,
		raise_built = true
	}
	box.minable = false
	return box
end
local function removeStorageChest(hub, buffer) -- only if it exists
	local box = hub.surface.find_entity(storage,position(storage_pos,hub))
	if box and box.valid then
		if buffer then retrieveItemsFromStorage(box, buffer) end
		box.destroy()
	end
end

local upgrades = {
	-- These are called on research completion to unlock hand-crafting recipes and building-undo recipes
	-- Tier 0 also has some HUB upgrades done here, and also unlocks the next HUB upgrade (or Tier 1/2 for the last one)
	-- This helps avoid polluting the tech effects screen
	-- Table of recipe names, with optional function for extra bits
	["hub-tier0-hub-upgrade-1"] = {
		"hub-tier0-hub-upgrade-2",
		"equipment-workshop-undo",
		function(force)
			local hub = findHubForForce(force)
			if hub and hub.valid then
				buildStorageChest(hub)
			end
		end
	},
	["hub-tier0-hub-upgrade-2"] = {
		"hub-tier0-hub-upgrade-3",
		"smelter-undo",
		"copper-ingot-manual",
		"wire-manual",
		"copper-cable-manual"
		-- TODO add biomass burner (and power pole)
	},
	["hub-tier0-hub-upgrade-3"] = {
		"hub-tier0-hub-upgrade-4",
		"constructor-undo",
		"small-electric-pole-undo",
		"concrete-manual",
		"scren-manual",
		"reinforced-iron-plate-manual"
	},
	["hub-tier0-hub-upgrade-4"] = {
		"hub-tier0-hub-upgrade-5",
		"transport-belt-undo"
	},
	["hub-tier0-hub-upgrade-5"] = {
		"hub-tier0-hub-upgrade-6",
		"miner-mk-1-undo",
		"iron-chest-undo"
		-- TODO add biomass burner (but no pole)
	},
	["hub-tier0-hub-upgrade-6"] = {
		-- Tier 1 & 2 turn-in items
		-- "space-elevator-undo",
		-- "biomass-burner-undo",
		"biomass-from-wood-manual",
		"biomass-from-leaves-manual"
		-- TODO add freighter
	}
	-- TODO Update floor graphics according to progression
}
local function completeMilestone(technology)
	if string.starts_with(technology.name, "hub-tier") then
		if not upgrades[technology.name] then
			technology.force.print("Milestone had no associated upgrade data")
			return
		end
		if not global['hub-milestones'] then global['hub-milestones'] = {} end
		if not global['hub-milestones'][technology.force.name] then global['hub-milestones'][technology.force.name] = {} end
		if global['hub-milestones'][technology.force.name][technology.name] then
			technology.force.print("Milestone already researched")
			return
		end
		global['hub-milestones'][technology.force.name][technology.name] = true
		for _,effect in pairs(upgrades[technology.name]) do
			if type(effect) == "function" then
				effect(technology.force)
			else
				technology.force.recipes[effect].enabled = true
			end
		end

		local message = {"", {"message.milestone-reached",technology.name,technology.localised_name}}
		-- use "real" technology effects for console message
		for _,effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" then
				-- if it has an associated "undo" recipe, it's a Building, otherwise it's an Equipment
				local subtype = technology.force.recipes[effect.recipe.."-undo"] and "building" or "equipment"
				table.insert(message, {"message.milestone-effect-unlock-"..subtype, effect.recipe, game.recipe_prototypes[effect.recipe].localised_name})
			elseif effect.type == "character-inventory-slots-bonus" then
				table.insert(message, {"message.milestone-effect-inventory-bonus",effect.modifier})
			elseif effect.type == "nothing" then
				table.insert(message, {"message.milestone-effect-other",effect.effect_description})
			else
				table.insert(message, {"message.milestone-effect-unknown",effect.type,effect.modifier or 0})
			end
		end
		technology.force.print(message)
	end
end

local function updateMilestoneGUI()
	local cache = {}
	for _,player in pairs(game.players) do
		if not cache[player.force.name] then
			local submitted = nil
			local hub = findHubForForce(player.force)
			local term = nil
			local recipe = nil
			local milestone = nil
			local ingredients = nil
			if hub and hub.valid then
				recipe = hub.get_recipe()
				if recipe then
					-- TODO Check if this Milestone has already been researched, and reject if so
					local inventory = hub.get_inventory(defines.inventory.assembling_machine_input)
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
							hub.surface.spill_item_stack(
								hub.position,
								{
									name = ingredient.name,
									count = inventory.remove{
										name = ingredient.name,
										count = submitted[ingredient.name] - ingredient.amount
									},
								},
								true,
								hub.force,
								false
							)
							submitted[ingredient.name] = ingredient.amount
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
			frame.add{type="label", caption={"","[item="..data.milestone.name.."] [font=heading-2]",data.milestone.localised_name,"[/font]"}}
			local inner = frame.add{type = "frame", style = "inside_shallow_frame", direction = "vertical"}
			inner.style.horizontally_stretchable = true
			inner.style.top_margin = 4
			inner.style.bottom_margin = 4
			local table = inner.add{
				type = "table",
				style = "bordered_table",
				column_count = 3
			}
			local ready = true -- set to false if any ingredient doesn't fulfill its need
			for key,ingredient in pairs(data.ingredients) do
				local sprite = table.add{type="sprite-button", sprite="item/"..ingredient.item.name, style="transparent_slot"}
				sprite.style.height = 20
				sprite.style.width = 20
				table.add{type="label", caption=ingredient.item.localised_name, style="bold_label"}
				local count_flow = table.add{type="flow"}
				local pusher = count_flow.add{type="empty-widget"}
				pusher.style.horizontally_stretchable = true
				count_flow.add{type="label", caption={"gui.fraction", util.format_number(data.submitted[key] or 0), ingredient.amount}}
				if (data.submitted[key] or 0) < ingredient.amount then
					ready = false
				end
			end
			local bottom = frame.add{type="flow"}
			local pusher = bottom.add{type="empty-widget"}
			pusher.style.horizontally_stretchable = true
			local btn = bottom.add{
				type = "button",
				style = "confirm_button",
				name = "hub-submit",
				caption = {"gui.hub-milestone-submit-caption"},
				enabled = ready
			}
		end
	end
end
local function submitMilestone(force)
	local hub = findHubForForce(force)
	if not hub or not hub.valid then return end
	local recipe = hub.get_recipe()
	if not recipe then return end
	local milestone = recipe.products[1].name
	if global['hub-milestones'] and global['hub-milestones'][force.name] and global['hub-milestones'][force.name][milestone] then return end
	local inventory = hub.get_inventory(defines.inventory.assembling_machine_input)
	local submitted = inventory.get_contents()
	for _,ingredient in pairs(recipe.ingredients) do
		if not submitted[ingredient.name] or submitted[ingredient.name] < ingredient.amount then return end
	end
	-- now that we've established that a recipe is set, it hasn't already been researched, and the maching contains enough items...
	for _,ingredient in pairs(recipe.ingredients) do
		inventory.remove{
			name = ingredient.name,
			count = ingredient.amount
		}
	end
	force.technologies[milestone].researched = true
	force.play_sound{path="utility/research_completed"}
	local spill = hub.set_recipe(nil)
	for name,count in pairs(spill) do
		hub.surface.spill_item_stack(
			hub.position,
			{
				name = name,
				count = count,
			},
			true,
			hub.force,
			false
		)
	end
end

return {
	name = hub,
	terminal = terminal,
	bench = bench,
	storage = storage,
	graphics = graphics,
	buildFloor = buildFloor,
	removeFloor = removeFloor,
	buildTerminal = buildTerminal,
	buildCraftBench = buildCraftBench,
	removeCraftBench = removeCraftBench,
	buildStorageChest = buildStorageChest,
	removeStorageChest = removeStorageChest,
	retrieveItemsFromCraftBench = retrieveItemsFromCraftBench,
	retrieveItemsFromStorage = retrieveItemsFromStorage,
	updateMilestoneGUI = updateMilestoneGUI,
	submitMilestone = submitMilestone,
	completeMilestone = completeMilestone
}
