-- uses global['hard-drive-research'] to record which alt recipes have been selected as rewards
local util = require("util")
local string = require("scripts.lualib.string")
local omnilab = require("scripts.lualib.omnilab")

local mam = "mam"

local function prepareHardDriveTech(force)
	-- check hard drive techs that have been unlocked but not completed...
	local valid = {}
	for _,tech in pairs(force.technologies) do
		if string.starts_with(tech.name, "alt-") and not tech.researched then
			local unlocked = true
			for _,req in pairs(tech.prerequisites) do
				if req.name ~= "mam-hard-drive" and not req.researched then
					unlocked = false
					break
				end
			end
			if unlocked then
				table.insert(valid, tech.name)
			end
		end
	end
	local selected = {}
	if #valid > 0 then
		for i=1,3 do
			local rand = math.random(#valid)
			table.insert(selected, valid[rand])
			table.remove(valid, rand)
		end
	end
	if not global['hard-drive-research'] then global['hard-drive-research'] = {} end
	global['hard-drive-research'][force.index] = {
		done = false,
		options = selected
	}
end
local function completeHardDriveTech(force)
	if global['hard-drive-research'] and global['hard-drive-research'][force.index] then
		global['hard-drive-research'][force.index].done = true
	end
end
local function clearHardDriveTech(force)
	global['hard-drive-research'][force.index] = nil
	force.recipes["mam-hard-drive"].enabled = true
	force.recipes["mam-hard-drive-done"].enabled = false
end
local function selectHardDriveReward(force,tech)
	local technology = force.technologies[tech]
	technology.researched = true
	local message = {"", {"message.hard-drive-research-complete","hard-drive",{"item-name.hard-drive"}}}
	-- use technology effects for console message
	local effect = technology.effects[1] -- almost always just one, only exception being Turbofuel packing and we don't care about that
	if effect.type == "unlock-recipe" then
		-- it's always a material
		table.insert(message, {"message.milestone-effect-unlock-material", effect.recipe, game.recipe_prototypes[effect.recipe].localised_name})
	elseif effect.type == "character-inventory-slots-bonus" then
		table.insert(message, {"message.milestone-effect-inventory-bonus",effect.modifier})
	else
		table.insert(message, {"message.milestone-effect-unknown",effect.type,effect.modifier or 0})
	end
	force.print(message)
	clearHardDriveTech(force)
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == mam then
		entity.active = false
	end
end

local function completeMam(technology)
	if string.starts_with(technology.name, "mam") then
		local message = {"", {"message.mam-research-complete",technology.name,technology.localised_name}}
		-- use technology effects for console message
		for _,effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" then
				-- if it has an associated "undo" recipe, it's a Building, otherwise it's an Equipment
				local subtype = "equipment"
				if technology.force.recipes[effect.recipe.."-undo"] then subtype = "building" end
				if technology.force.recipes[effect.recipe].products[1].type == "fluid" or not game.item_prototypes[technology.force.recipes[effect.recipe].products[1].name].place_result then subtype = "material" end
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
		if technology.name == "mam-hard-drive" then
			completeHardDriveTech(technology.force)
		end
	end
end
local function manageMamGUI(player)
	if not player then
		for _,p in pairs(game.players) do
			manageMamGUI(p)
		end
		return
	end
	if player.opened_gui_type ~= defines.gui_type.entity then
		if player.gui.left['mam-tracking'] then
			player.gui.left['mam-tracking'].destroy()
		end
		return
	end
	local entity = player.opened
	local gui = player.gui.left
	local frame = gui['mam-tracking']
	if not (entity and entity.valid and entity.name == mam) then
		if frame then frame.destroy() end
		return
	end
	
	-- check its recipe and inventory
	local recipe = entity.get_recipe()
	if not recipe then
		if frame then frame.destroy() end
	else
		local research = game.item_prototypes[recipe.products[1].name]
		if not entity.force.recipes[research.name].enabled then
			-- research already completed, so reject it
			if frame then frame.destroy() end
			local spill = entity.set_recipe(nil)
			for name,count in pairs(spill) do
				entity.surface.spill_item_stack(
					entity.position,
					{
						name = name,
						count = count,
					},
					true, entity.force, false
				)
			end
			entity.force.print({"message.mam-already-done",research.name,research.localised_name})
		else
			if frame and frame['mam-tracking-name'..research.name] then
				-- research has changed, re-create GUI
				frame.destroy()
				frame = nil
			end
			if not frame then
				frame = gui.add{
					type = "frame",
					name = "mam-tracking",
					direction = "vertical",
					caption = {"gui.mam-tracking-caption"},
					style = "inner_frame_in_outer_frame"
				}
				frame.style.horizontally_stretchable = false
				frame.style.use_header_filler = false
				frame.add{
					type = "label",
					name = "mam-tracking-name-"..research.name,
					caption = {"","[img=recipe/"..research.name.."] [font=heading-2]",research.localised_name,"[/font]"}
				}
				local bottom = frame.add{
					type = "flow",
					name = "mam-tracking-bottom"
				}
				local pusher = bottom.add{type="empty-widget"}
				pusher.style.horizontally_stretchable = true
				local button = bottom.add{
					type = "button",
					style = "confirm_button",
					name = "mam-tracking-submit",
					caption = {"gui.mam-submit-caption"}
				}
				button.style.top_margin = 8
			end

			local inventory = entity.get_inventory(defines.inventory.assembling_machine_input)
			submitted = inventory.get_contents()
			local ready = true
			for _,ingredient in ipairs(recipe.ingredients) do
				if (submitted[ingredient.name] or 0) < ingredient.amount then
					ready = false
				end
			end
			frame['mam-tracking-bottom']['mam-tracking-submit'].enabled = ready
		end
	end
end
local function submitMam(event)
	if not (event.element and event.element.valid and event.element.name == "mam-tracking-submit") then return end
	-- the GUI only exists if the player has a M.A.M. open, but double-check just to be sure
	local player = game.players[event.player_index]
	local entity = player.opened
	if not (entity and entity.valid and entity.name == mam) then return end
	local recipe = entity.get_recipe()
	if not recipe then return end
	local force = player.force
	
	local research = recipe.products[1].name
	if not force.recipes[research].enabled then return end
	local inventory = entity.get_inventory(defines.inventory.assembling_machine_input)
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
	-- place appropriate item in the Omnilab and start the research process
	local lab = omnilab.getOmnilab(force)
	lab.insert{name=research,count=1}
	force.research_queue = {research}
	force.print({"message.mam-research-started",research,{"item-name."..research}})

	local spill = entity.set_recipe(nil)
	for name,count in pairs(spill) do
		entity.surface.spill_item_stack(
			entity.position,
			{
				name = name,
				count = count,
			},
			true,
			entity.force,
			false
		)
	end

	-- disable the recipe and enable the "-done" recipe
	force.recipes[research].enabled = false
	force.recipes[research.."-done"].enabled = true

	if research == "mam-hard-drive" then
		prepareHardDriveTech(force)
	end
end

local function onResearch(event)
	-- can just pass all researches to the function, since that already checks if it's a mam tech.
	completeMam(event.research)
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.name ~= mam then return end
	if not global['hard-drive-research'] then return end
	local struct = global['hard-drive-research'][player.force.index]
	if not struct or not struct.done then return end

	if #struct.options == 0 then
		-- player has unlocked all things, so refund the hard drive
		clearHardDriveTech(player.force)
		local spilled = event.entity.set_recipe("mam-hard-drive")
		event.entity.insert{name="hard-drive",count=1}
		for item,count in pairs(spilled) do
			event.entity.surface.spill_item_stack(event.entity.position, {name=item,count=count}, true, player.force, false)
		end
		player.force.print{"message.all-alt-recipes-unlocked"}
	else
		-- force completed a hard drive research, pop up a window requesting confirmation of what reward is wanted
		local gui = player.gui.screen.add{
			type = "frame",
			name = "hard-drive-reward",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = gui.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.hard-drive-reward-title"}, style = "frame_title"}
		title.drag_target = gui
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
		pusher.style.height = 24
		pusher.style.horizontally_stretchable = true
		pusher.drag_target = gui
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "hard-drive-reward-close"}

		local columns = gui.add{
			type = "flow",
			name = "columns"
		}
		columns.style.horizontal_spacing = 12
		for _,name in pairs(struct.options) do
			local effect = game.technology_prototypes[name].effects[1]
			local title, image, recipe, text
			if effect.type == "unlock-recipe" then
				title = {"recipe-name."..effect.recipe}
				image = "recipe/"..effect.recipe
				recipe = game.recipe_prototypes[effect.recipe]
			else
				title = {"technology-name."..name}
				image = "technology/mam-sulfur-inflated-pocket-dimension"
				text = {"modifier-description.character-inventory-slots-bonus",effect.modifier}
			end
			local col = columns.add{
				type = "frame",
				style = "inside_shallow_frame",
				direction = "vertical",
				name = name
			}
			local head = col.add{
				type = "frame",
				style = "subheader_frame"
			}
			head.style.horizontally_stretchable = true
			head.add{
				type = "label",
				style = "heading_2_label",
				caption = title
			}
			local list = col.add{
				type = "flow",
				direction = "vertical",
				name = "details"
			}
			list.style.padding = 12
			list.style.horizontally_stretchable = true
			list.style.minimal_width = 240
			list.style.horizontal_align = "center"
			local spritebox = list.add{
				type = "frame",
				style = "deep_frame_in_shallow_frame"
			}
			spritebox.style.padding = 4
			local sprite = spritebox.add{
				type = "sprite",
				sprite = image
			}
			sprite.style.width = 64
			sprite.style.height = 64
			sprite.style.stretch_image_to_widget_size = true
			if recipe then
				local craft = list.add{
					type = "table",
					style = "bordered_table",
					column_count = 2
				}
				craft.style.top_margin = 8
				craft.style.bottom_margin = 8
				for _,ingredient in pairs(recipe.ingredients) do
					craft.add{
						type = "sprite",
						sprite = ingredient.type.."/"..ingredient.name
					}
					craft.add{
						type = "label",
						caption = {"gui.hard-drive-recipe-ingredient",{ingredient.type.."-name."..ingredient.name},ingredient.amount}
					}
				end
				craft.add{type="empty-widget"}
				craft.add{
					type = "label",
					caption = {"gui.hard-drive-recipe-time",{"time-symbol-seconds-short",recipe.energy},{"description.crafting-time"}}
				}
				craft.add{type="empty-widget"}
				craft.add{type="empty-widget"}
				craft.add{
					type = "sprite",
					sprite = recipe.products[1].type.."/"..recipe.products[1].name
				}
				craft.add{
					type = "label",
					caption = {"gui.hard-drive-recipe-ingredient",{recipe.products[1].type.."-name."..recipe.products[1].name},recipe.products[1].amount}
				}
			else
				local desc = list.add{
					type = "label",
					style = "description_label",
					caption = text
				}
				desc.style.top_margin = 8
				desc.style.bottom_margin = 8
			end
			local pusher = list.add{type = "empty-widget"}
			pusher.style.vertically_stretchable = true
			list.add{
				type = "button",
				style = "confirm_button",
				name = "hard-drive-reward-select",
				caption = {"gui.hard-drive-reward-select"}
			}
		end
		player.opened = gui
		gui.force_auto_center()
	end
end
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "hard-drive-reward" then
		event.element.destroy()
	end
end
local function onGuiClick(event)
	if event.element and event.element.valid then
		local player = game.players[event.player_index]
		if event.element.name == "mam-tracking-submit" then
			submitMam(event)
		elseif event.element.name == "hard-drive-reward-close" then
			local gui = player.gui.screen['hard-drive-reward']
			if gui then gui.destroy() end
		elseif event.element.name == "hard-drive-reward-select" then
			-- element grandparent's name is the name of the selected hard drive tech
			selectHardDriveReward(player.force, event.element.parent.parent.name)
			for _,player in pairs(player.force.players) do
				local gui = player.gui.screen['hard-drive-reward']
				if gui then gui.destroy() end
			end
		end
	end
end

return {
	on_nth_tick = {
		[6] = function(event) manageMamGUI() end
	},
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_research_finished] = onResearch,

		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick
	}
}
