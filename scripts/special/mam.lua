local mod_gui = require("mod-gui")
local util = require("util")
local string = require("scripts.lualib.string")
local omnilab = require("scripts.lualib.omnilab")

local mam = "mam"

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
	end
end
local function manageMamGUI(player)
	if not player then
		for _,p in pairs(game.players) do
			manageMamGUI(p)
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
					style = mod_gui.frame_style
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
end

local function onResearch(event)
	-- can just pass all researches to the function, since that already checks if it's a mam tech.
	completeMam(event.research)
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
		[defines.events.on_gui_click] = submitMam
	}
}
