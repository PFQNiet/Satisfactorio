-- uses global['hub-terminal'] as table of Force name -> {surface, position} of the HUB terminal
-- uses global['hub-milestones'] as table of Force name -> milestone[]
-- uses global['hub-milestone-gui'] as table of Force name -> milestone shown in GUI - if different to current selection then GUI needs refresh, otherwise just update counts

local mod_gui = require("mod-gui")
local util = require("util")
local string = require("scripts.lualib.string")
local omnilab = require("scripts.lualib.omnilab")

local hub = "the-hub"
local terminal = "the-hub-terminal"
local bench = "craft-bench"
local storage = "wooden-chest"
local biomassburner = "biomass-burner-hub"
local powerpole = "small-electric-pole"
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
local function retrieveItemsFromBurner(burner, target)
	-- collect items from the Personal Storage inventory and place them in target event buffer
	local source = burner.get_inventory(defines.inventory.fuel)
	for i = 1, #source do
		local stack = source[i]
		if stack.valid and stack.valid_for_read then
			if target then
				target.insert(stack)
			else
				burner.surface.spill_item_stack(burner.position, stack, true, burner.force, false)
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
local burner_1_pos = {2,-4}
local burner_2_pos = {-2,-4}
local powerpole_pos = {0,-5}

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

local function buildBiomassBurner1(hub)
	-- only if HUB Upgrade 2 is done
	if not (global['hub-milestones'] and global['hub-milestones'][hub.force.name] and global['hub-milestones'][hub.force.name]['hub-tier0-hub-upgrade-2']) then
		return
	end
	local burner = hub.surface.create_entity{
		name = biomassburner,
		position = position(burner_1_pos,hub),
		force = hub.force,
		raise_built = true
	}
	burner.minable = false
	local pole = hub.surface.create_entity{
		name = powerpole,
		position = position(powerpole_pos,hub),
		force = hub.force,
		raise_built = true
	}
	pole.minable = false
	return burner, pole
end
local function removeBiomassBurner1(hub, buffer) -- only if it exists
	local burner = hub.surface.find_entity(biomassburner,position(burner_1_pos,hub))
	if burner and burner.valid then
		if buffer then retrieveItemsFromBurner(burner, buffer) end
		burner.destroy()
	end
	local pole = hub.surface.find_entity(powerpole,position(powerpole_pos,hub))
	if pole and pole.valid then
		pole.destroy()
	end
end
local function buildBiomassBurner2(hub)
	-- only if HUB Upgrade 5 is done
	if not (global['hub-milestones'] and global['hub-milestones'][hub.force.name] and global['hub-milestones'][hub.force.name]['hub-tier0-hub-upgrade-5']) then
		return
	end
	local burner = hub.surface.create_entity{
		name = biomassburner,
		position = position(burner_2_pos,hub),
		force = hub.force,
		raise_built = true
	}
	burner.minable = false
	return burner
end
local function removeBiomassBurner2(hub, buffer) -- only if it exists
	local burner = hub.surface.find_entity(biomassburner,position(burner_2_pos,hub))
	if burner and burner.valid then
		if buffer then retrieveItemsFromBurner(burner, buffer) end
		burner.destroy()
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
		"copper-cable-manual",
		function(force)
			local hub = findHubForForce(force)
			if hub and hub.valid then
				buildBiomassBurner1(hub)
			end
		end
	},
	["hub-tier0-hub-upgrade-3"] = {
		"hub-tier0-hub-upgrade-4",
		"constructor-undo",
		"small-electric-pole-undo",
		"concrete-manual",
		"screw-manual",
		"reinforced-iron-plate-manual"
	},
	["hub-tier0-hub-upgrade-4"] = {
		"hub-tier0-hub-upgrade-5",
		"transport-belt-undo"
	},
	["hub-tier0-hub-upgrade-5"] = {
		"hub-tier0-hub-upgrade-6",
		"miner-mk-1-undo",
		"iron-chest-undo",
		function(force)
			local hub = findHubForForce(force)
			if hub and hub.valid then
				buildBiomassBurner2(hub)
			end
		end
	},
	["hub-tier0-hub-upgrade-6"] = {
		-- Tier 1 & 2 turn-in items
		-- "space-elevator-undo",
		"biomass-burner-undo",
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
				local subtype = "equipment"
				if technology.force.recipes[effect.recipe.."-undo"] then subtype = "building" end
				if not game.item_prototypes[technology.force.recipes[effect.recipe].products[1].name].place_result then subtype = "material" end
				if technology.force.recipes[effect.recipe].category == "resource-scanner" then subtype = "resource" end
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

local function updateMilestoneGUI(force)
	if not force then
		for _,force in pairs(game.forces) do
			updateMilestoneGUI(force)
		end
		return
	end

	if not global['hub-milestone-gui'] then global['hub-milestone-gui'] = {} end

	local hub = findHubForForce(force)
	local milestone = {name="none"}
	local recipe
	local submitted
	-- if a HUB exists for this force, check its recipe and inventory
	if hub and hub.valid then
		recipe = hub.get_recipe()
		if recipe then
			milestone = game.item_prototypes[recipe.products[1].name]
			-- TODO Check if this Milestone has already been researched, and reject if so
			local inventory = hub.get_inventory(defines.inventory.assembling_machine_input)
			submitted = inventory.get_contents()
			for _,ingredient in ipairs(recipe.ingredients) do
				if submitted[ingredient.name] and submitted[ingredient.name] > ingredient.amount then
					-- spill the excess
					hub.surface.spill_item_stack(
						hub.position,
						{
							name = ingredient.name,
							count = inventory.remove{
								name = ingredient.name,
								count = submitted[ingredient.name] - ingredient.amount
							}
						},
						true, hub.force, false
					)
					submitted[ingredient.name] = ingredient.amount
				end
			end
		end
	end

	for _,player in pairs(force.players) do
		local gui = mod_gui.get_frame_flow(player)
		local frame = gui['hub-milestone-tracking']
		-- create the GUI if it doesn't exist yet (should only happen once per player)
		if not frame then
			frame = gui.add{
				type = "frame",
				name = "hub-milestone-tracking",
				direction = "vertical",
				caption = {"gui.hub-milestone-tracking-caption"},
				style = mod_gui.frame_style
			}
			frame.style.use_header_filler = false
			frame.add{
				type = "label",
				name = "hub-milestone-tracking-name",
				caption = {"","[font=heading-2]",{"gui.hub-milestone-tracking-none-selected"},"[/font]"}
			}
			local inner = frame.add{
				type = "frame",
				name = "hub-milestone-tracking-content",
				style = "inside_shallow_frame",
				direction = "vertical"
			}
			inner.style.horizontally_stretchable = true
			inner.style.top_margin = 4
			inner.style.bottom_margin = 4
			inner.add{
				type = "table",
				name = "hub-milestone-tracking-table",
				style = "bordered_table",
				column_count = 3
			}
			local bottom = frame.add{
				type = "flow",
				name = "hub-milestone-tracking-bottom"
			}
			local pusher = bottom.add{type="empty-widget"}
			pusher.style.horizontally_stretchable = true
			bottom.add{
				type = "button",
				style = "confirm_button",
				name = "hub-milestone-tracking-submit",
				caption = {"gui.hub-milestone-submit-caption"}
			}
		end

		-- gather up GUI element references
		local name = frame['hub-milestone-tracking-name']
		local inner = frame['hub-milestone-tracking-content']
		local table = inner['hub-milestone-tracking-table']
		local bottom = frame['hub-milestone-tracking-bottom']
		local button = bottom['hub-milestone-tracking-submit']

		-- check if the selected milestone has been changed
		if milestone.name ~= global['hub-milestone-gui'][force.name] then
			global['hub-milestone-gui'][force.name] = milestone.name
			inner.visible = milestone.name ~= "none"
			bottom.visible = inner.visible
			button.enabled = false
			table.clear()
			if milestone.name == "none" then
				name.caption = {"","[font=heading-2]",{"gui.hub-milestone-tracking-none-selected"},"[/font]"}
			else
				-- if milestone is actually set then we know this is valid
				name.caption = {"","[img=item/"..milestone.name.."] [font=heading-2]",milestone.localised_name,"[/font]"}
				for _,ingredient in ipairs(recipe.ingredients) do
					local sprite = table.add{
						type = "sprite-button",
						sprite = "item/"..ingredient.name,
						style = "transparent_slot"
					}
					sprite.style.width = 20
					sprite.style.height = 20
					table.add{
						type = "label",
						caption = game.item_prototypes[ingredient.name].localised_name,
						style = "bold_label"
					}
					local count_flow = table.add{
						type = "flow",
						name = "hub-milestone-tracking-ingredient-"..ingredient.name
					}
					local pusher = count_flow.add{type="empty-widget"}
					pusher.style.horizontally_stretchable = true
					count_flow.add{
						type = "label",
						name = "hub-milestone-tracking-ingredient-"..ingredient.name.."-count",
						caption = {"gui.fraction", -1, -1} -- unset by default, will be populated in the next block
					}
				end
			end
		end

		-- so now we've established the GUI exists, and is populated with a table for the currently selected milestone... if there is one, update the counts now
		if milestone.name ~= "none" then
			local ready = true
			for _,ingredient in ipairs(recipe.ingredients) do
				local label = table['hub-milestone-tracking-ingredient-'..ingredient.name]['hub-milestone-tracking-ingredient-'..ingredient.name..'-count']
				label.caption = {"gui.fraction", util.format_number(submitted[ingredient.name] or 0), util.format_number(ingredient.amount)}
				if (submitted[ingredient.name] or 0) < ingredient.amount then
					ready = false
				end
			end
			button.enabled = ready
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
	buildBiomassBurner1 = buildBiomassBurner1,
	removeBiomassBurner1 = removeBiomassBurner1,
	buildBiomassBurner2 = buildBiomassBurner2,
	removeBiomassBurner2 = removeBiomassBurner2,
	retrieveItemsFromCraftBench = retrieveItemsFromCraftBench,
	retrieveItemsFromStorage = retrieveItemsFromStorage,
	retrieveItemsFromBurner = retrieveItemsFromBurner,
	updateMilestoneGUI = updateMilestoneGUI,
	submitMilestone = submitMilestone,
	completeMilestone = completeMilestone
}
