-- uses global.hub.terminal as table of Force index -> HUB terminal
-- uses global.hub.milestone_selected as table of Player index -> milestone shown in GUI - if different to current selection then GUI needs refresh, otherwise just update counts
-- uses global.hub.cooldown as table of Force index -> tick at which the Freighter returns
local util = require("util")
local math2d = require("math2d")
local string = require(modpath.."scripts.lualib.string")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local base = "the-hub"
local terminal = "the-hub-terminal"
local bench = "craft-bench"
local storage = "personal-storage-box"
local biomassburner = "biomass-burner-hub"
local powerpole = "power-pole-mk-1"
local freighter = "ficsit-freighter"

---@class global.hub
---@field terminal table<uint, LuaEntity>
---@field milestone_selected table<uint, string> Player index => which Milestone the GUI was last updated for
---@field cooldown table<uint, uint> Force index => Tick at which the Freighter returns
local script_data = {
	terminal = {},
	milestone_selected = {},
	cooldown = {}
}

---@param entity LuaEntity
local function ejectColliders(entity)
	local colliders = entity.surface.find_entities_filtered{
		area = entity.bounding_box,
		collision_mask = "train-layer"
	}
	for _,other in pairs(colliders) do
		other.teleport(other.surface.find_non_colliding_position(other.name, other.position, 0, 0.1, false))
	end
end

--- Asserts that the terminal is valid before returning it
---@param force LuaForce
---@return LuaEntity|nil
local function findHubForForce(force)
	local term = script_data.terminal[force.index]
	if term and not term.valid then
		script_data.terminal[force.index] = nil
		return nil
	end
	return term
end

--- Establish a target position
---@param offset Position Assuming entity is facing North
---@param entity LuaEntity Its position and direction are factored in
---@return Position
local function position(offset,entity)
	return math2d.position.add(entity.position, math2d.position.rotate_vector(offset, entity.direction*45))
end

local spawn_pos = {1,0}
local bench_pos = {2.5,0}
local bench_rotation = 2 -- 90deg
local storage_pos = {0,2}
local burner_1_pos = {-4,2}
local burner_2_pos = {-4,-2}
local powerpole_pos = {-5,0}
local freighter_pos = {6,0}

---@param floor LuaEntity
local function buildTerminal(floor)
	local term = floor.surface.create_entity{
		name = terminal,
		position = floor.position,
		direction = floor.direction,
		force = floor.force,
		raise_built = true
	}
	term.active = false -- "crafting" is faked :D
	term.force.set_spawn_position(position(spawn_pos,term), term.surface)
	link.register(term, floor)
	script_data.terminal[term.force.index] = term
	return term
end

---@param term LuaEntity
local function buildCraftBench(term)
	local craft = term.surface.create_entity{
		name = bench,
		position = position(bench_pos,term),
		direction = (term.direction+bench_rotation)%8,
		force = term.force,
		raise_built = true
	}
	craft.minable = false
	link.register(term, craft)
	return craft
end

---@param term LuaEntity
local function buildStorageChest(term)
	-- only if HUB Upgrade 1 is done
	if not term.force.technologies['hub-tier0-hub-upgrade1'].researched then
		return
	end
	local box = term.surface.create_entity{
		name = storage,
		position = position(storage_pos,term),
		force = term.force,
		raise_built = true
	}
	box.minable = false
	ejectColliders(box)
	link.register(term, box)
	return box
end

---@param term LuaEntity
local function buildBiomassBurner1(term)
	-- only if HUB Upgrade 2 is done
	if not term.force.technologies['hub-tier0-hub-upgrade2'].researched then
		return
	end
	local burner = term.surface.create_entity{
		name = biomassburner,
		position = position(burner_1_pos,term),
		force = term.force,
		raise_built = true
	}
	burner.minable = false
	local pole = term.surface.create_entity{
		name = powerpole,
		position = position(powerpole_pos,term),
		force = term.force,
		raise_built = true
	}
	pole.minable = false
	ejectColliders(burner)
	ejectColliders(pole)
	link.register(term, burner)
	link.register(term, pole)
	return burner, pole
end
---@param term LuaEntity
local function buildBiomassBurner2(term)
	-- only if HUB Upgrade 5 is done
	if not term.force.technologies['hub-tier0-hub-upgrade5'].researched then
		return
	end
	local burner = term.surface.create_entity{
		name = biomassburner,
		position = position(burner_2_pos,term),
		force = term.force,
		raise_built = true
	}
	burner.minable = false
	ejectColliders(burner)
	link.register(term, burner)
	return burner
end

---@param term LuaEntity
local function buildFreighter(term)
	-- only if HUB Upgrade 6 is done
	if not term.force.technologies['hub-tier0-hub-upgrade6'].researched then
		return
	end
	local silo = term.surface.create_entity{
		name = freighter,
		position = position(freighter_pos,term),
		force = term.force,
		raise_built = true
	}
	silo.operable = false
	silo.auto_launch = true

	local inserter = term.surface.create_entity{
		name = "loader-inserter",
		position = silo.position,
		force = term.force,
		raise_built = true
	}
	inserter.drop_position = silo.position
	inserter.operable = false

	ejectColliders(silo)
	link.register(term, silo)
	link.register(term, inserter)
end

---@param term LuaEntity
---@param item string
local function launchFreighter(term, item)
	if not term then return end
	local silo = term.surface.find_entity(freighter,position(freighter_pos,term))
	if not (silo and silo.valid) then
		term.force.print("Could not find Freighter")
		return
	end
	local inserter = term.surface.find_entity("loader-inserter",position(freighter_pos,term))
	if not (inserter and inserter.valid) then
		term.force.print("Could not find Freighter Loader")
		return
	end
	inserter.held_stack.set_stack({name=item, count=1})
	silo.rocket_parts = 1
end

--- "building" recipes have only one item product and that item is only-in-cursor
---@param recipe LuaRecipePrototype
local function isRecipeABuilding(recipe)
	local products = recipe.products
	-- assert there is only one product
	if #products ~= 1 then return end
	local product = products[1]
	if product.type ~= "item" then return end
	local item = game.item_prototypes[product.name]
	-- if it is only-in-cursor then it's a building
	return item.has_flag("only-in-cursor")
end
--- "material" recipes are any recipe in the "intermediate-products" or "space-elevator" groups
---@param recipe LuaRecipePrototype
local function isRecipeAMaterial(recipe)
	return recipe.group.name == "intermediate-products" or recipe.group.name == "space-elevator"
end

local upgrades = {
	["hub-tier0-hub-upgrade1"] = buildStorageChest,
	["hub-tier0-hub-upgrade2"] = buildBiomassBurner1,
	["hub-tier0-hub-upgrade5"] = buildBiomassBurner2,
	["hub-tier0-hub-upgrade6"] = buildFreighter
}
---@param technology LuaTechnology
local function completeMilestone(technology)
	if upgrades[technology.name] then
		local hub = findHubForForce(technology.force)
		if hub and hub.valid then
			upgrades[technology.name](hub)
		end
	end

	if game.tick > 5 then
		local message = {"", {"message.milestone-reached",technology.name,technology.localised_name}}
		-- use "real" technology effects for console message
		for _,effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" and effect.recipe:find("^hub%-tier%d+$") then
				if effect.recipe == "hub-tier1" then
					-- only register it once
					table.insert(message, {"message.hub-new-tiers-available"})
				end
			elseif effect.type == "unlock-recipe" then
				local recipe = game.recipe_prototypes[effect.recipe]
				local subtype
				if recipe.category == "resource-scanner" then
					subtype = "resource"
				elseif isRecipeABuilding(recipe) then
					subtype = "building"
				elseif isRecipeAMaterial(recipe) then
					subtype = "material"
				else
					subtype = "equipment"
				end
				table.insert(message, {"message.milestone-effect-unlock-"..subtype, effect.recipe, recipe.localised_name})
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

	-- launch freighter if needed
	local time = technology.research_unit_energy
	if time > 30*60 then
		launchFreighter(findHubForForce(technology.force), technology.research_unit_ingredients[1].name)
		script_data.cooldown[technology.force.index] = game.tick + time
	end
end

---@param force LuaForce
local function updateMilestoneGUI(force)
	local hub = findHubForForce(force)
	local milestone = {name="none"}
	local recipe
	local submitted
	-- if a HUB exists for this force, check its recipe and inventory
	if hub and hub.valid then
		recipe = hub.get_recipe()
		if recipe then
			if #recipe.ingredients == 0 then
				-- is a Tier marker
				hub.set_recipe(nil)
				milestone = {name="none"}
			else
				milestone = game.item_prototypes[recipe.products[1].name]
					if force.technologies[milestone.name].researched then
					-- milestone already completed, so reject it
					local spill = hub.set_recipe(nil)
					for name,count in pairs(spill) do
						hub.surface.spill_item_stack(hub.position, {name = name, count = count}, true, force, false)
					end
					if milestone.name == recipe.name then
						force.recipes[recipe.name].enabled = false
						force.recipes[recipe.name.."-done"].enabled = true
					end
					-- print warning message to any player(s) that has the hub open
					for _,player in pairs(force.players) do
						if player.opened == hub then
							player.print({"message.milestone-already-researched",milestone.name,milestone.localised_name})
						end
					end
					milestone = {name="none"}
				else
					local inventory = hub.get_inventory(defines.inventory.assembling_machine_input)
					submitted = inventory.get_contents()
					local progress = {0,0}
					for _,ingredient in ipairs(recipe.ingredients) do
						if submitted[ingredient.name] then progress[1] = progress[1] + math.min(submitted[ingredient.name],ingredient.amount) end
						progress[2] = progress[2] + ingredient.amount
					end
					hub.crafting_progress = progress[1] / progress[2]
				end
			end
		end
	end

	for _,player in pairs(force.players) do
		local gui = player.gui.left
		local frame = gui['hub-milestone']
		-- create the GUI if it doesn't exist yet, but only once a HUB has been built for the first time
		if not frame and force.technologies['the-hub'].researched then
			frame = gui.add{
				type = "frame",
				name = "hub-milestone",
				direction = "vertical",
				caption = {"gui.hub-milestone-tracking-caption"},
				style = "inner_frame_in_outer_frame"
			}
			frame.style.horizontally_stretchable = false
			frame.style.use_header_filler = false
			frame.add{
				type = "label",
				name = "hub-milestone-name",
				caption = {"","[font=heading-2]",{"gui.hub-milestone-tracking-none-selected"},"[/font]"}
			}
			local inner = frame.add{
				type = "frame",
				name = "hub-milestone-content",
				style = "inside_shallow_frame",
				direction = "vertical"
			}
			inner.style.horizontally_stretchable = true
			inner.style.top_margin = 4
			inner.style.bottom_margin = 4
			inner.add{
				type = "table",
				name = "hub-milestone-table",
				style = "bordered_table",
				column_count = 3
			}
			local cooldown = frame.add{
				type = "label",
				name = "hub-milestone-cooldown"
			}
			cooldown.visible = false
		end
		gui = player.gui.relative
		local flow = gui['hub-milestone']
		if frame and not flow then
			flow = gui.add{
				type = "flow",
				name = "hub-milestone",
				anchor = {
					gui = defines.relative_gui_type.assembling_machine_gui,
					position = defines.relative_gui_position.bottom,
					name = terminal
				},
				direction = "horizontal"
			}
			flow.add{type="empty-widget"}.style.horizontally_stretchable = true
			local frame = flow.add{
				type = "frame",
				name = "hub-milestone-frame",
				direction = "horizontal",
				style = "inset_frame_container_frame"
			}
			frame.style.horizontally_stretchable = false
			frame.style.use_header_filler = false
			local button = frame.add{
				type = "button",
				style = "confirm_button",
				name = "hub-milestone-submit",
				caption = {"gui.hub-milestone-submit-caption"}
			}
		end

		if frame then
			-- gather up GUI element references
			local name = frame['hub-milestone-name']
			local inner = frame['hub-milestone-content']
			local table = inner['hub-milestone-table']
			local cooldown = frame['hub-milestone-cooldown']
			local button = flow['hub-milestone-frame']['hub-milestone-submit']

			-- check if the selected milestone has been changed
			if milestone.name ~= script_data.milestone_selected[player.index] then
				script_data.milestone_selected[player.index] = milestone.name
				inner.visible = milestone.name ~= "none"
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
							name = "hub-milestone-ingredient-"..ingredient.name
						}
						local pusher = count_flow.add{type="empty-widget"}
						pusher.style.horizontally_stretchable = true
						count_flow.add{
							type = "label",
							name = "hub-milestone-ingredient-"..ingredient.name.."-count",
							caption = {"gui.fraction", -1, -1} -- unset by default, will be populated in the next block
						}
					end
				end
			end

			-- so now we've established the GUI exists, and is populated with a table for the currently selected milestone... if there is one, update the counts now
			local ready = true
			local current_cooldown = script_data.cooldown[player.force.index]
			if current_cooldown then
				if current_cooldown > game.tick then
					ready = false
					local ticks = current_cooldown - game.tick
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
					local label = table['hub-milestone-ingredient-'..ingredient.name]['hub-milestone-ingredient-'..ingredient.name..'-count']
					label.caption = {"gui.fraction", util.format_number(math.min(submitted[ingredient.name] or 0, ingredient.amount)), util.format_number(ingredient.amount)}
					if (submitted[ingredient.name] or 0) < ingredient.amount then
						ready = false
					end
				end
				button.enabled = ready
			end
		end
	end
end
---@param force LuaForce
---@param player LuaPlayer
local function submitMilestone(force,player)
	local hub = findHubForForce(force)
	if not hub or not hub.valid then return end
	local recipe = hub.get_recipe()
	if not recipe then return end
	local milestone = recipe.products[1].name
	if force.technologies[milestone].researched then return end
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
	for name,count in pairs(inventory.get_contents()) do
		if player then
			count = count - player.insert{name=name,count=count}
		end
		if count > 0 then
			hub.surface.spill_item_stack(
				hub.position,
				{name = name, count = count},
				true, force, false
			)
		end
	end
	hub.set_recipe(nil)
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		local term = buildTerminal(entity)
		buildCraftBench(term)
		buildStorageChest(term)
		buildBiomassBurner1(term)
		buildBiomassBurner2(term)
		buildFreighter(term)

		-- if this is the first time building, then complete the "build the HUB" tech
		local force = entity.force
		if not force.technologies['the-hub'].researched then
			force.research_queue = {"the-hub"}
			force.technologies['the-hub'].researched = true
			force.play_sound{path="utility/research_completed"}
		end
	end
end

local function on10thTick()
	for _,force in pairs(game.forces) do
		updateMilestoneGUI(force)
	end
end
---@param event on_research_finished
local function onResearch(event)
	if string.starts_with(event.research.name, "hub-tier") then
		completeMilestone(event.research)
	end
end
local function onGuiOpened(event)
	if event.entity and event.entity.name == terminal and event.entity.get_recipe() == nil then
		-- double-check for, and disable, any recipes that have completed technologies
		local force = event.entity.force
		for _,recipe in pairs(force.recipes) do
			if force.technologies[recipe.name] and force.recipes[recipe.name.."-done"] and force.technologies[recipe.name].researched then
				force.recipes[recipe.name].enabled = false
				force.recipes[recipe.name.."-done"].enabled = true
			end
		end
	end
end
local function onGuiClick(event)
	if event.element and event.element.valid and event.element.name == "hub-milestone-submit" then
		local player = game.players[event.player_index]
		submitMilestone(player.force, player)
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.hub = global.hub or script_data
	end,
	on_load = function()
		script_data = global.hub or script_data
	end,
	on_nth_tick = {
		[6] = on10thTick
	},
	on_build = onBuilt,
	events = {
		[defines.events.on_research_finished] = onResearch,
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_click] = onGuiClick
	}
}
