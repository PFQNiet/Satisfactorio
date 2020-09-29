-- uses global['hub-terminal'] as table of Force index -> {surface, position} of the HUB terminal
-- uses global['hub-milestone-selected'] as table of Force index -> milestone shown in GUI - if different to current selection then GUI needs refresh, otherwise just update counts
-- uses global['hub-cooldown'] as table of Force index -> tick at which the Freighter returns

local mod_gui = require("mod-gui")
local util = require("util")
local string = require("scripts.lualib.string")
local omnilab = require("scripts.lualib.omnilab")
local getitems = require("scripts.lualib.get-items-from")

local base = "the-hub"
local terminal = "the-hub-terminal"
local bench = "craft-bench"
local storage = "wooden-chest"
local biomassburner = "biomass-burner-hub"
local powerpole = "small-electric-pole"
local freighter = "ficsit-freighter"
local graphics = {
	[defines.direction.north] = base.."-north",
	[defines.direction.east] = base.."-east",
	[defines.direction.south] = base.."-south",
	[defines.direction.west] = base.."-west"
}

local function findHubForForce(force)
	local pos = global['hub-terminal'] and global['hub-terminal'][force.index] or nil
	if not pos then return nil end
	return game.get_surface(pos[1]).find_entity(terminal,pos[2])
end
local function retrieveItemsFromCraftBench(bench, target)
	getitems.assembler(bench, target)
end
local function retrieveItemsFromStorage(box, target)
	getitems.storage(box, target)
end
local function retrieveItemsFromBurner(burner, target)
	getitems.burner(burner, target)
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
local freighter_pos = {0,6}

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
	global['hub-terminal'][hub.force.index] = nil
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
	global['hub-terminal'][terminal.force.index] = {terminal.surface.index, terminal.position}
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
		getitems.assembler(craft, target)
	end
	craft.destroy()
end

local function buildStorageChest(hub)
	-- only if HUB Upgrade 1 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade-1'].researched then
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
		if buffer then
			getitems.storage(box, target)
		end
		box.destroy()
	end
end

local function buildBiomassBurner1(hub)
	-- only if HUB Upgrade 2 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade-2'].researched then
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
		if buffer then
			getitems.burner(burner, target)
		end
		burner.destroy()
	end
	local pole = hub.surface.find_entity(powerpole,position(powerpole_pos,hub))
	if pole and pole.valid then
		pole.destroy()
	end
end
local function buildBiomassBurner2(hub)
	-- only if HUB Upgrade 5 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade-5'].researched then
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
		if buffer then
			getitems.burner(burner, target)
		end
		burner.destroy()
	end
end
local function buildFreighter(hub)
	-- only if HUB Upgrade 6 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade-6'].researched then
		return
	end
	local silo = hub.surface.create_entity{
		name = freighter,
		position = position(freighter_pos,hub),
		force = hub.force,
		raise_built = true
	}
	silo.operable = false
	silo.minable = false
	silo.auto_launch = true

	local inserter = hub.surface.create_entity{
		name = "loader-inserter",
		position = silo.position,
		force = hub.force,
		raise_built = true
	}
	inserter.drop_position = silo.position
	inserter.operable = false
	inserter.minable = false
	inserter.destructible = false
end
local function removeFreighter(hub, buffer)
	local silo = hub.surface.find_entity(freighter,position(freighter_pos,hub))
	if silo and silo.valid then
		silo.destroy()
	end
	local inserter = hub.surface.find_entity("loader-inserter",position(freighter_pos,hub))
	if inserter and inserter.valid then
		inserter.destroy()
	end
end
local function launchFreighter(hub, item)
	if not hub then return end
	local silo = hub.surface.find_entity(freighter,position(freighter_pos,hub))
	if not (silo and silo.valid) then
		game.print("Could not find Freighter")
		return
	end
	local inserter = hub.surface.find_entity("loader-inserter",position(freighter_pos,hub))
	if not (inserter and inserter.valid) then
		game.print("Could not find Freighter Loader")
		return
	end
	inserter.held_stack.set_stack({name=item, count=1})
	silo.rocket_parts = 1
end

local upgrades = {
	["hub-tier0-hub-upgrade-1"] = buildStorageChest,
	["hub-tier0-hub-upgrade-2"] = buildBiomassBurner1,
	["hub-tier0-hub-upgrade-5"] = buildBiomassBurner2,
	["hub-tier0-hub-upgrade-6"] = buildFreighter
}
local function completeMilestone(technology)
	if string.starts_with(technology.name, "hub-tier") then
		if upgrades[technology.name] then
			local hub = findHubForForce(technology.force)
			if hub and hub.valid then
				upgrades[technology.name](hub)
			end
		end
		-- disable the recipe and enable the "-done" recipe
		technology.force.recipes[technology.name].enabled = false
		technology.force.recipes[technology.name.."-done"].enabled = true
		-- find techs that depend on the tech we just did, and unlock their associated recipe items
		for _,tech in pairs(technology.force.technologies) do
			for _,req in pairs(tech.prerequisites) do
				if req.name == technology.name then
					technology.force.recipes[tech.name].enabled = true
				end
			end
		end

		local message = {"", {"message.milestone-reached",technology.name,technology.localised_name}}
		-- use "real" technology effects for console message
		for _,effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" then
				-- if it has an associated "undo" recipe, it's a Building, otherwise it's an Equipment
				local subtype = "equipment"
				if technology.force.recipes[effect.recipe.."-undo"] then subtype = "building" end
				if technology.force.recipes[effect.recipe].products[1].type == "fluid" or not game.item_prototypes[technology.force.recipes[effect.recipe].products[1].name].place_result then subtype = "material" end
				if technology.force.recipes[effect.recipe].category == "resource-scanner" then subtype = "resource" end
				table.insert(message, {"message.milestone-effect-unlock-"..subtype, effect.recipe, game.recipe_prototypes[effect.recipe].localised_name})
				if technology.force.recipes[effect.recipe.."-undo"] then
					technology.force.recipes[effect.recipe.."-undo"].enabled = true
				end
				if technology.force.recipes[effect.recipe.."-manual"] then
					technology.force.recipes[effect.recipe.."-manual"].enabled = true
				end
			elseif effect.type == "character-inventory-slots-bonus" then
				table.insert(message, {"message.milestone-effect-inventory-bonus",effect.modifier})
			elseif effect.type == "nothing" then
				table.insert(message, {"message.milestone-effect-other",effect.effect_description})
			else
				table.insert(message, {"message.milestone-effect-unknown",effect.type,effect.modifier or 0})
			end
		end
		technology.force.print(message)
		-- launch freighter if needed
		local time = technology.research_unit_energy
		if time > 30*60 then
			launchFreighter(findHubForForce(technology.force), technology.research_unit_ingredients[1].name)
			if not global['hub-cooldown'] then global['hub-cooldown'] = {} end
			global['hub-cooldown'][technology.force.index] = game.tick + time
		end
	end
end

local function updateMilestoneGUI(force)
	if not force then
		for _,force in pairs(game.forces) do
			updateMilestoneGUI(force)
		end
		return
	end

	if not global['hub-milestone-selected'] then global['hub-milestone-selected'] = {} end

	local hub = findHubForForce(force)
	local milestone = {name="none"}
	local recipe
	local submitted
	-- if a HUB exists for this force, check its recipe and inventory
	if hub and hub.valid then
		recipe = hub.get_recipe()
		if recipe then
			milestone = game.item_prototypes[recipe.products[1].name]
			if not force.recipes[milestone.name].enabled then
				-- milestone already completed, so reject it
				local spill = hub.set_recipe(nil)
				for name,count in pairs(spill) do
					hub.surface.spill_item_stack(
						hub.position,
						{
							name = name,
							count = count,
						},
						true, hub.force, false
					)
				end
				force.print({"message.milestone-already-researched",milestone.name,milestone.localised_name})
				milestone = {name="none"}
			else
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
	end

	for _,player in pairs(force.players) do
		local gui = player.gui.left
		local frame = gui['hub-milestone-tracking']
		-- wait until the HUB has been built for the first time, as determined by the Omnilab being set up
		if global['omnilab'] and global['omnilab'][player.force.index] then
			-- create the GUI if it doesn't exist yet (should only happen once per player)
			if not frame then
				frame = gui.add{
					type = "frame",
					name = "hub-milestone-tracking",
					direction = "vertical",
					caption = {"gui.hub-milestone-tracking-caption"},
					style = mod_gui.frame_style
				}
				frame.style.horizontally_stretchable = false
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
				local cooldown = frame.add{
					type = "label",
					name = "hub-milestone-tracking-cooldown"
				}
				cooldown.visible = false
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
			local cooldown = frame['hub-milestone-tracking-cooldown']
			local bottom = frame['hub-milestone-tracking-bottom']
			local button = bottom['hub-milestone-tracking-submit']

			-- check if the selected milestone has been changed
			if milestone.name ~= global['hub-milestone-selected'][force.index] then
				global['hub-milestone-selected'][force.index] = milestone.name
				inner.visible = milestone.name ~= "none"
				bottom.visible = inner.visible
				button.enabled = false
				table.clear()
				if milestone.name == "none" then
					name.caption = {"","[font=heading-2]",{"gui.hub-milestone-tracking-none-selected"},"[/font]"}
				else
					-- if milestone is actually set then we know this is valid
					name.caption = {"","[img=recipe/"..milestone.name.."] [font=heading-2]",milestone.localised_name,"[/font]"}
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
			local ready = true
			if global['hub-cooldown'] and global['hub-cooldown'][player.force.index] then
				if global['hub-cooldown'][player.force.index] > game.tick then
					ready = false
					local ticks = global['hub-cooldown'][player.force.index] - game.tick
					local tenths = math.floor(ticks/6)%10
					local seconds = math.floor(ticks/60)
					local minutes = math.floor(seconds/60)
					seconds = seconds % 60
					local seconds_padding = seconds < 10 and "0" or ""
					cooldown.caption = {"gui.hub-milestone-cooldown", minutes, seconds_padding, seconds, tenths}
					cooldown.visible = true
				else
					cooldown.visible = false
				end
			end
			if milestone.name ~= "none" then
				for _,ingredient in ipairs(recipe.ingredients) do
					local label = table['hub-milestone-tracking-ingredient-'..ingredient.name]['hub-milestone-tracking-ingredient-'..ingredient.name..'-count']
					label.caption = {"gui.fraction", util.format_number(submitted[ingredient.name] or 0), util.format_number(ingredient.amount)}
					if (submitted[ingredient.name] or 0) < ingredient.amount then
						ready = false
					end
				end
				button.visible = player.opened and player.opened == hub
				button.enabled = ready
			end
		end
	end
end
local function submitMilestone(force)
	local hub = findHubForForce(force)
	if not hub or not hub.valid then return end
	local recipe = hub.get_recipe()
	if not recipe then return end
	local milestone = recipe.products[1].name
	if not force.recipes[milestone].enabled then return end
	local inventory = hub.get_inventory(defines.inventory.assembling_machine_input)
	local submitted = inventory.get_contents()
	for _,ingredient in pairs(recipe.ingredients) do
		if not submitted[ingredient.name] or submitted[ingredient.name] < ingredient.amount then return end
	end
	-- now that we've established that a recipe is set, it hasn't already been researched, and the machine contains enough items...
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

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		buildFloor(entity)
		buildTerminal(entity)
		buildCraftBench(entity)
		buildStorageChest(entity)
		buildBiomassBurner1(entity)
		buildBiomassBurner2(entity)
		buildFreighter(entity)
		-- remove base item
		entity.destroy()
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == terminal then
		removeCraftBench(entity, event and event.buffer or nil)
		removeStorageChest(entity, event and event.buffer or nil)
		removeBiomassBurner1(entity, event and event.buffer or nil)
		removeBiomassBurner2(entity, event and event.buffer or nil)
		removeFreighter(entity, event and event.buffer or nil)
		removeFloor(entity)
	end
end

local function onTick(event)
	updateMilestoneGUI()
end
local function onResearch(event)
	-- can just pass all researches to the HUB library, since that already checks if it's a HUB tech.
	completeMilestone(event.research)
end
local function onGuiClick(event)
	if event.element.name == "hub-milestone-tracking-submit" then
		submitMilestone(game.players[event.player_index].force)
	end
end

return {
	on_nth_tick = {
		[6] = onTick
	},
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,
		
		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,
		
		[defines.events.on_research_finished] = onResearch,
		[defines.events.on_gui_click] = onGuiClick
	}
}
