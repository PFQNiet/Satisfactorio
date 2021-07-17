local gui = {
	mam = require(modpath.."scripts.gui.mam"),
	hard_drive = require(modpath.."scripts.gui.hard-drive")
}

local bev = require(modpath.."scripts.lualib.build-events")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local string = require(modpath.."scripts.lualib.string")

local mam = "mam"
local lab = "omnilab"

---@class HardDriveData
---@field done boolean
---@field options LuaTechnologyPrototype[] Chosen hard drive techs to unlock

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
				table.insert(valid, tech.prototype)
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
	local struct = script_data.hard_drive[force.index]
	if struct then
		struct.done = true
		gui.hard_drive.force_gui(force, struct.options)
	end
end
---@param force LuaForce
local function clearHardDriveTech(force)
	script_data.hard_drive[force.index] = nil
	force.recipes["mam-hard-drive"].enabled = true
	force.recipes["mam-hard-drive-done"].enabled = false
end

---@param player LuaPlayer
---@param tech LuaTechnologyPrototype
gui.hard_drive.callbacks.select = function(player, tech)
	local force = player.force
	-- ensure selected option is in the list of presented options
	local valid = false
	local options = {}
	for i,test in pairs(script_data.hard_drive[force.index].options) do
		options[i] = tech.name
		if test == tech then
			valid = true
			break
		end
	end
	assert(valid, "Attempted to complete "..tech.name.." but options are "..table.concat(options, ", "))

	local technology = force.technologies[tech.name]
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
				elseif recipe.category == "building" then
					subtype = "building"
				elseif recipe.group.name == "intermediate-products" or recipe.group.name == "space-elevator" then
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
local function updateMam(player)
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local entity = player.opened
	if not (entity and entity.valid and entity.name == mam) then return end

	-- check its recipe and inventory
	local recipe = entity.get_recipe()
	if recipe then
		local research = game.item_prototypes[recipe.products[1].name]
		local force = entity.force
		if force.technologies[research.name].researched
		or (force.current_research and force.current_research.name == research.name and force.research_progress > 0)
		or ((force.get_saved_technology_progress(research.name) or 0) > 0) then
			-- research already completed, so reject it
			getitems.assembler(entity, player.get_main_inventory())
			entity.set_recipe(nil)
			if research.name == recipe.name then
				force.recipes[recipe.name].enabled = false
				force.recipes[recipe.name.."-done"].enabled = true
			end
			player.print{"message.mam-already-done",research.name,research.localised_name}
		else
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
			gui.mam.set_enabled(player, ready)
		end
	end
end

local function updateAllPlayers()
	for _,p in pairs(game.players) do
		updateMam(p)
	end
end

---@param player LuaPlayer
---@param entity LuaEntity
gui.mam.callbacks.submit = function(player, entity)
	if not (entity and entity.valid) then return end
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
	force.print{"message.mam-research-started",research,game.technology_prototypes[research].localised_name}

	getitems.assembler(entity, player.get_main_inventory())
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
	local entity = event.entity
	if entity.name ~= mam then return end
	if entity.get_recipe() == nil then
		-- double-check for, and disable, any recipes that have completed technologies
		local force = entity.force
		for _,recipe in pairs(force.recipes) do
			if force.technologies[recipe.name] and force.recipes[recipe.name.."-done"] and force.technologies[recipe.name].researched then
				force.recipes[recipe.name].enabled = false
				force.recipes[recipe.name.."-done"].enabled = true
			end
		end
	else
		gui.mam.open_gui(player, entity)
		updateMam(player)
	end

	local struct = script_data.hard_drive[player.force.index]
	if not struct or not struct.done then return end

	if #struct.options == 0 then
		-- player has unlocked all things, so refund the hard drive
		clearHardDriveTech(player.force)
		getitems.assembler(entity, player.get_main_inventory())
		entity.set_recipe("mam-hard-drive")
		entity.insert{name="hard-drive",count=1}
		player.force.print{"message.all-alt-recipes-unlocked"}
	else
		gui.hard_drive.open_gui(player, struct.options)
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
		[6] = function() updateAllPlayers() end
	},
	on_build = onBuilt,
	events = {
		[defines.events.on_research_finished] = onResearch,

		[defines.events.on_gui_opened] = onGuiOpened
	}
}
