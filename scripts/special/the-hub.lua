local gui = {
	tracker = require(modpath.."scripts.gui.the-hub-tracker"),
	terminal = require(modpath.."scripts.gui.the-hub-terminal")
}

-- uses global.hub.terminal as table of Force index -> HUB terminal
-- uses global.hub.cooldown as table of Force index -> tick at which the Freighter returns
local util = require("util")
local math2d = require("math2d")
local string = require(modpath.."scripts.lualib.string")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")
local getitems = require(modpath.."scripts.lualib.get-items-from")

local base = "the-hub"
local terminal = "the-hub-terminal"
local bench = "craft-bench"
local storage = "personal-storage-box"
local biomassburner = "biomass-burner-hub"
local powerpole = "power-pole-mk-1"
local freighter = "ficsit-freighter"

---@class HubData
---@field valid boolean If the HUB has been built; cooldown is still available even if not valid
---@field force LuaForce
---@field surface LuaSurface
---@field position Position
---@field direction defines.direction
---@field floor LuaEntity
---@field terminal LuaEntity
---@field bench LuaEntity
---@field storage LuaEntity
---@field burner1 LuaEntity
---@field burner2 LuaEntity
---@field powerpole LuaEntity
---@field freighter LuaEntity
---@field inserter LuaEntity
---@field cooldown uint Tick at which the Freighter returns

---@alias global.hub table<uint, HubData> Force index => HUB
---@type global.hub
local script_data = {}

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

---@param force LuaForce
---@return HubData|nil
local function findHubForForce(force)
	if not script_data[force.index] then
		script_data[force.index] = {
			valid = false,
			force = force,
			cooldown = 0
		}
	end
	return script_data[force.index]
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

---@param hub HubData
---@return LuaEntity Terminal
local function buildTerminal(hub)
	local term = hub.surface.create_entity{
		name = terminal,
		position = hub.position,
		direction = hub.direction,
		force = hub.force,
		raise_built = true
	}
	term.active = false -- "crafting" is faked :D
	term.force.set_spawn_position(position(spawn_pos,term), term.surface)

	link.register(term, hub.floor)
	hub.terminal = term

	return term
end

---@param hub HubData
---@return LuaEntity CraftBench
local function buildCraftBench(hub)
	local craft = hub.surface.create_entity{
		name = bench,
		position = position(bench_pos,hub),
		direction = (hub.direction+bench_rotation)%8,
		force = hub.force,
		raise_built = true
	}
	craft.minable = false

	link.register(hub.terminal, craft)
	hub.bench = craft

	return craft
end

---@param hub HubData
---@return LuaEntity Storage
local function buildStorageChest(hub)
	-- only if HUB Upgrade 1 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade1'].researched then
		return
	end
	local box = hub.surface.create_entity{
		name = storage,
		position = position(storage_pos,hub),
		force = hub.force,
		raise_built = true
	}
	box.minable = false

	ejectColliders(box)
	link.register(hub.terminal, box)
	hub.storage = box

	return box
end

---@param hub HubData
---@return LuaEntity Burner
---@return LuaEntity PowerPole
local function buildBiomassBurner1(hub)
	-- only if HUB Upgrade 2 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade2'].researched then
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

	ejectColliders(burner)
	link.register(hub.terminal, burner)
	hub.burner1 = burner

	ejectColliders(pole)
	link.register(hub.terminal, pole)
	hub.powerpole = pole

	return burner, pole
end
---@param hub HubData
---@return LuaEntity Burner
local function buildBiomassBurner2(hub)
	-- only if HUB Upgrade 5 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade5'].researched then
		return
	end
	local burner = hub.surface.create_entity{
		name = biomassburner,
		position = position(burner_2_pos,hub),
		force = hub.force,
		raise_built = true
	}
	burner.minable = false

	ejectColliders(burner)
	link.register(hub.terminal, burner)
	hub.burner2 = burner

	return burner
end

---@param hub HubData
---@return LuaEntity Freighter
---@return LuaEntity Inserter
local function buildFreighter(hub)
	-- only if HUB Upgrade 6 is done
	if not hub.force.technologies['hub-tier0-hub-upgrade6'].researched then
		return
	end
	local silo = hub.surface.create_entity{
		name = freighter,
		position = position(freighter_pos,hub),
		force = hub.force,
		raise_built = true
	}
	silo.operable = false
	silo.auto_launch = true

	local inserter = hub.surface.create_entity{
		name = "loader-inserter",
		position = silo.position,
		force = hub.force,
		raise_built = true
	}
	inserter.drop_position = silo.position
	inserter.operable = false

	ejectColliders(silo)
	link.register(hub.terminal, silo)
	link.register(hub.terminal, inserter)

	hub.freighter = silo
	hub.inserter = inserter
	return silo, inserter
end

---@param hub HubData
---@param item string
local function launchFreighter(hub, item)
	if not (hub and hub.valid) then return end
	local silo = hub.freighter
	local inserter = hub.inserter
	inserter.held_stack.set_stack({name=item, count=1})
	silo.rocket_parts = 1
end

---@type table<string, fun(hub:HubData)>
local upgrades = {
	["hub-tier0-hub-upgrade1"] = buildStorageChest,
	["hub-tier0-hub-upgrade2"] = buildBiomassBurner1,
	["hub-tier0-hub-upgrade5"] = buildBiomassBurner2,
	["hub-tier0-hub-upgrade6"] = buildFreighter
}
---@param technology LuaTechnology
local function completeMilestone(technology)
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

	local hub = findHubForForce(technology.force)
	if hub then
		if hub.valid and upgrades[technology.name] then
			upgrades[technology.name](hub)
		end

		-- launch freighter if needed
		local time = technology.research_unit_energy
		if time > 30*60 then
			launchFreighter(hub, technology.research_unit_ingredients[1].name)
			hub.cooldown = game.tick + time
		end
	end
end

---@param force LuaForce
local function updateMilestoneGUI(force)
	local hub = findHubForForce(force)
	local milestone = {name="none"}
	local recipe
	local submitted
	-- if a HUB exists for this force, check its recipe and inventory
	if (hub and hub.valid) then
		recipe = hub.terminal.get_recipe()
		if recipe then
			if #recipe.ingredients == 0 then
				-- is a Tier marker
				hub.terminal.set_recipe(nil)
				milestone = {name="none"}
			else
				milestone = game.item_prototypes[recipe.products[1].name]
				if force.technologies[milestone.name].researched then
					local player = hub.terminal.last_user
					-- milestone already completed, so reject it
					getitems.assembler(hub.terminal, player and player.get_main_inventory())
					hub.terminal.set_recipe(nil)
					if milestone.name == recipe.name then
						force.recipes[recipe.name].enabled = false
						force.recipes[recipe.name.."-done"].enabled = true
					end
					player.print{"message.milestone-already-researched",milestone.name,milestone.localised_name}
					milestone = {name="none"}
				else
					local inventory = hub.terminal.get_inventory(defines.inventory.assembling_machine_input)
					submitted = inventory.get_contents()
					local progress = {0,0}
					for _,ingredient in ipairs(recipe.ingredients) do
						if submitted[ingredient.name] then progress[1] = progress[1] + math.min(submitted[ingredient.name],ingredient.amount) end
						progress[2] = progress[2] + ingredient.amount
					end
					hub.terminal.crafting_progress = progress[1] / progress[2]
				end
			end
		end
	end

	for _,player in pairs(force.players) do
		local ready = gui.tracker.update_gui(player, recipe and recipe.prototype, hub.cooldown, submitted)
		gui.terminal.set_enabled(player, ready)
	end
end

---@param player LuaPlayer
---@param term LuaEntity
gui.terminal.callbacks.submit = function(player, term)
	local hub = findHubForForce(player.force)
	if not (hub and hub.valid) then return end
	local recipe = hub.terminal.get_recipe()
	if not recipe then return end
	local force = player.force

	local milestone = recipe.products[1].name
	if force.technologies[milestone].researched then return end
	local inventory = hub.terminal.get_inventory(defines.inventory.assembling_machine_input)
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

	getitems.assembler(hub.terminal, player.get_main_inventory())
	hub.terminal.set_recipe(nil)
end

---@param event on_build
local function onBuilt(event)
	---@type LuaEntity
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		local hub = findHubForForce(entity.force)
		if hub.valid then
			-- player has somehow managed to build two HUBs
			-- since this indicates some kind of glitch, the editor, or cross-force shenanigans, do not refund the cost
			entity.last_user.create_local_flying_text{
				text = {"message.hub-only-one-allowed"},
				create_at_cursor = true
			}
			entity.last_user.play_sound{path="utility/cannot_build"}
			entity.destroy()
			return
		end
		hub.valid = true
		hub.floor = entity
		-- cache some properties of the floor
		hub.surface = entity.surface
		hub.position = entity.position
		hub.direction = entity.direction
		buildTerminal(hub)
		buildCraftBench(hub)
		buildStorageChest(hub)
		buildBiomassBurner1(hub)
		buildBiomassBurner2(hub)
		buildFreighter(hub)

		-- if this is the first time building, then complete the "build the HUB" tech
		local force = hub.force
		if not force.technologies['the-hub'].researched then
			force.research_queue = {"the-hub"}
			force.technologies['the-hub'].researched = true
			force.play_sound{path="utility/research_completed"}
		end
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	-- the terminal is the only minable entity
	if entity.valid and entity.name == terminal then
		local hub = findHubForForce(entity.force)
		hub.valid = false
	end
end

local function on6thTick()
	for _,force in pairs(game.forces) do
		updateMilestoneGUI(force)
	end
end
---@param event on_research_finished
local function onResearch(event)
	if string.starts_with(event.research.name, "hub-tier") then
		completeMilestone(event.research)
	end
	if event.research.name == "the-hub" then
		for _,p in pairs(event.research.force.players) do
			gui.tracker.create_gui(p)
		end
	end
end
local function onGuiOpened(event)
	local entity = event.entity
	if entity and entity.valid and entity.name == terminal then
		local player = game.players[event.player_index]
		gui.terminal.open_gui(player, entity)
		if entity.get_recipe() == nil then
			-- double-check for, and disable, any recipes that have completed technologies
			local force = entity.force
			for _,recipe in pairs(force.recipes) do
				if force.technologies[recipe.name] and force.recipes[recipe.name.."-done"] and force.technologies[recipe.name].researched then
					force.recipes[recipe.name].enabled = false
					force.recipes[recipe.name.."-done"].enabled = true
				end
			end
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.hub = global.hub or script_data
	end,
	on_load = function()
		script_data = global.hub or script_data
	end,
	on_configuration_changed = function()
		for _,p in pairs(game.players) do
			local gui = p.gui.left['hub-milestone']
			if gui and not gui.content then
				gui.destroy()
			end
		end
	end,
	on_nth_tick = {
		[6] = on6thTick
	},
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_research_finished] = onResearch,
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
