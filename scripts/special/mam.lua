local bev = require(modpath.."scripts.lualib.build-events")
local string = require(modpath.."scripts.lualib.string")

local mam = "mam"
local lab = "omnilab"

---@class HardDriveData
---@field done boolean
---@field options string Chosen hard drive techs to unlock

---@class global.mam
---@field lab table<uint, LuaEntity> Force index => Omnilab
---@field hard_drive table<uint, HardDriveData> Force index => Selected rewards
local script_data = {
	lab = {},
	hard_drive = {}
}

---@param force LuaForce
local function getOmnilab(force)
	local omnilab = script_data.lab[force.index]
	if not (omnilab and omnilab.valid) then
		omnilab = game.surfaces.nauvis.create_entity{
			name = lab,
			position = {0,0},
			force = force,
			raise_built = true
		}
		omnilab.operable = false
		script_data.lab[force.index] = omnilab
	end
	return omnilab
end
-- check hard drive techs that have been unlocked but not completed
---@param force LuaForce
local function prepareHardDriveTech(force)
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
		for _=1,3 do
			local rand = math.random(#valid)
			table.insert(selected, valid[rand])
			table.remove(valid, rand)
			if #valid == 0 then break end
		end
	end
	script_data.hard_drive[force.index] = {
		done = false,
		options = selected
	}
end
---@param force LuaForce
local function completeHardDriveTech(force)
	if script_data.hard_drive[force.index] then
		script_data.hard_drive[force.index].done = true
	end
end
---@param force LuaForce
local function clearHardDriveTech(force)
	script_data.hard_drive[force.index] = nil
	force.recipes["mam-hard-drive"].enabled = true
	force.recipes["mam-hard-drive-done"].enabled = false
end
---@param force LuaForce
---@param tech string
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

---@param technology LuaTechnology
local function completeMam(technology)
	if game.tick > 5 then
		local message = {"", {"message.mam-research-complete",technology.name,technology.localised_name}}
		-- use technology effects for console message
		for _,effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" then
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
	if technology.name == "mam-hard-drive" then
		completeHardDriveTech(technology.force)
	end
end
---@param player LuaPlayer
local function manageMamGUI(player)
	if not player then
		for _,p in pairs(game.players) do
			manageMamGUI(p)
		end
		return
	end
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local entity = player.opened
	if not (entity and entity.valid and entity.name == mam) then return end
	local gui = player.gui.relative
	local flow = gui['mam']

	-- check its recipe and inventory
	local recipe = entity.get_recipe()
	if recipe then
		local research = game.item_prototypes[recipe.products[1].name]
		local force = entity.force
		if force.technologies[research.name].researched
		or (force.current_research and force.current_research.name == research.name and force.research_progress > 0)
		or ((force.get_saved_technology_progress(research.name) or 0) > 0) then
			-- research already completed, so reject it
			local spill = entity.set_recipe(nil)
			for name,count in pairs(spill) do
				entity.surface.spill_item_stack(entity.position, {name = name, count = count}, true, force, false)
			end
			if research.name == recipe.name then
				force.recipes[recipe.name].enabled = false
				force.recipes[recipe.name.."-done"].enabled = true
			end
			force.print({"message.mam-already-done",research.name,research.localised_name})
		else
			if not flow then
				flow = gui.add{
					type = "flow",
					name = "mam",
					anchor = {
						gui = defines.relative_gui_type.assembling_machine_gui,
						position = defines.relative_gui_position.bottom,
						name = mam
					},
					direction = "horizontal"
				}
				flow.add{type="empty-widget"}.style.horizontally_stretchable = true
				local frame = flow.add{
					type = "frame",
					name = "mam-frame",
					direction = "horizontal",
					style = "inset_frame_container_frame"
				}
				frame.style.horizontally_stretchable = false
				frame.style.use_header_filler = false
				local button = frame.add{
					type = "button",
					style = "confirm_button",
					name = "mam-submit",
					caption = {"gui.mam-submit-caption"}
				}
			end

			local inventory = entity.get_inventory(defines.inventory.assembling_machine_input)
			local submitted = inventory.get_contents()
			local ready = true
			local progress = {0,0}
			for _,ingredient in ipairs(recipe.ingredients) do
				if submitted[ingredient.name] then progress[1] = progress[1] + math.min(submitted[ingredient.name],ingredient.amount) end
				progress[2] = progress[2] + ingredient.amount
				if (submitted[ingredient.name] or 0) < ingredient.amount then
					ready = false
				end
			end
			entity.crafting_progress = progress[1] / progress[2]
			flow['mam-frame']['mam-submit'].enabled = ready
		end
	end
end
---@param event on_gui_click
local function submitMam(event)
	if not (event.element and event.element.valid and event.element.name == "mam-submit") then return end
	-- the GUI only exists if the player has a M.A.M. open, but double-check just to be sure
	local player = game.players[event.player_index]
	local entity = player.opened
	if not (entity and entity.valid and entity.name == mam) then return end
	local recipe = entity.get_recipe()
	if not recipe then return end
	local force = player.force

	local research = recipe.products[1].name
	if force.technologies[research].researched then return end
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
	local omnilab = getOmnilab(force)
	omnilab.insert{name=research,count=1}
	force.research_queue = {research}
	force.print({"message.mam-research-started",research,game.technology_prototypes[research].localised_name})

	for name,count in pairs(inventory.get_contents()) do
		count = count - player.insert{name=name,count=count}
		if count > 0 then
			player.surface.spill_item_stack(
				player.position,
				{name = name, count = count},
				true, force, false
			)
		end
	end
	entity.set_recipe(nil)

	-- disable the recipe and enable the "-done" recipe
	force.recipes[research].enabled = false
	force.recipes[research.."-done"].enabled = true

	if research == "mam-hard-drive" then
		prepareHardDriveTech(force)
	end
end

---@param event on_research_finished
local function onResearch(event)
	if string.starts_with(event.research.name, "mam-") then
		completeMam(event.research)
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.name ~= mam then return end
	if event.entity.get_recipe() == nil then
		-- double-check for, and disable, any recipes that have completed technologies
		local force = event.entity.force
		for _,recipe in pairs(force.recipes) do
			if force.technologies[recipe.name] and force.recipes[recipe.name.."-done"] and force.technologies[recipe.name].researched then
				force.recipes[recipe.name].enabled = false
				force.recipes[recipe.name.."-done"].enabled = true
			end
		end
	else
		manageMamGUI(player)
	end

	local struct = script_data.hard_drive[player.force.index]
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
				image = "utility/character_inventory_slots_bonus_modifier_icon"
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
				local getname = function(what)
					return game[what.type.."_prototypes"][what.name].localised_name
				end
				for _,ingredient in pairs(recipe.ingredients) do
					craft.add{
						type = "sprite",
						sprite = ingredient.type.."/"..ingredient.name
					}
					craft.add{
						type = "label",
						caption = {"gui.hard-drive-recipe-ingredient",getname(ingredient),ingredient.amount}
					}
				end
				craft.add{type="empty-widget"}
				craft.add{
					type = "label",
					caption = {"gui.hard-drive-recipe-time",{"time-symbol-seconds-short",recipe.energy},{"description.crafting-time"}}
				}
				craft.add{type="empty-widget"}
				craft.add{type="empty-widget"}
				for _,product in pairs(recipe.products) do
					craft.add{
						type = "sprite",
						sprite = product.type.."/"..product.name
					}
					craft.add{
						type = "label",
						caption = {"gui.hard-drive-recipe-ingredient",getname(product),product.amount}
					}
				end
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
---@param event on_gui_closed
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "hard-drive-reward" then
		event.element.destroy()
	end
end
---@param event on_gui_click
local function onGuiClick(event)
	if event.element and event.element.valid then
		local player = game.players[event.player_index]
		if event.element.name == "mam-submit" then
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

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == mam then
		entity.active = false
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.mam = global.mam or script_data
	end,
	on_load = function()
		script_data = global.mam or script_data
	end,
	on_nth_tick = {
		[6] = function() manageMamGUI() end
	},
	on_build = onBuilt,
	events = {
		[defines.events.on_research_finished] = onResearch,

		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick
	}
}
