local gui = require(modpath.."scripts.gui.space-elevator")
local string = require(modpath.."scripts.lualib.string")
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local refundEntity = require(modpath.."scripts.lualib.building-management").refundEntity
local link = require(modpath.."scripts.lualib.linked-entity")

local elevator = "space-elevator"

---@class SpaceElevator
---@field elevator LuaEntity
---@field silo LuaEntity
---@field inserter LuaEntity

---@class global.space_elevator
---@field elevator table<uint, SpaceElevator> Force ID => Elevator
local script_data = {
	elevator = {}
}
local debounce_error = {}

---@param force LuaForce
local function findElevatorForForce(force)
	return script_data.elevator[force.index]
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == elevator then
		if findElevatorForForce(entity.force) then
			local player = entity.last_user
			refundEntity(player, entity)
			if not debounce_error[player.force.index] or debounce_error[player.force.index] < event.tick then
				player.create_local_flying_text{
					text = {"message.space-elevator-only-one-allowed"},
					create_at_cursor = true
				}
				player.play_sound{
					path = "utility/cannot_build"
				}
				debounce_error[player.force.index] = event.tick + 60
			end
			return
		else
			-- position hack to avoid it trying to drop stuff in the rocket silo
			local target_hack = {position={entity.position.x-8,entity.position.y}}
			io.addConnection(entity, {-10,13}, "input", target_hack)
			io.addConnection(entity, {-8,13}, "input", target_hack)
			io.addConnection(entity, {-6,13}, "input", target_hack)
			io.addConnection(entity, {-10,-13}, "input", target_hack, defines.direction.south)
			io.addConnection(entity, {-8,-13}, "input", target_hack, defines.direction.south)
			io.addConnection(entity, {-6,-13}, "input", target_hack, defines.direction.south)

			local silo = entity.surface.create_entity{
				name = elevator.."-silo",
				position = entity.position,
				force = entity.force,
				raise_built = true
			}
			silo.operable = false
			silo.auto_launch = true
			link.register(entity, silo)

			local inserter = silo.surface.create_entity{
				name = "loader-inserter",
				position = silo.position,
				force = silo.force,
				raise_built = true
			}
			inserter.drop_position = silo.position
			inserter.operable = false
			link.register(entity, inserter)

			script_data.elevator[entity.force.index] = {
				elevator = entity,
				silo = silo,
				inserter = inserter
			}
			entity.rotatable = false
			entity.active = false
		end
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == elevator then
		script_data.elevator[entity.force.index] = nil
	end
end

---@param struct SpaceElevator
local function launchFreighter(struct, item)
	if not struct then return end
	struct.inserter.held_stack.set_stack{name=item, count=1}
	struct.silo.rocket_parts = 1
end

---@param technology LuaTechnology
local function completeElevator(technology)
	if game.tick > 5 then
		local message = {"message.space-elevator-complete",technology.name,technology.localised_name}
		local newtiers = false
		for _,effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" then
				newtiers = true
				break
			end
		end
		if newtiers then
			technology.force.print({"",message,{"message.hub-new-tiers-available"}})
		else
			technology.force.print(message)
		end
	end
	launchFreighter(findElevatorForForce(technology.force), technology.research_unit_ingredients[1].name)
end

---@param player LuaPlayer
local function updateElevator(player)
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local entity = player.opened
	if not (entity and entity.valid and entity.name == elevator) then return end

	-- check its recipe and inventory
	local recipe = entity.get_recipe()
	if recipe then
		local phase = game.item_prototypes[recipe.products[1].name]
		local force = player.force
		if force.technologies[phase.name].researched then
			-- phase already completed, so reject it
			getitems.assembler(entity, player.get_main_inventory())
			if phase.name == recipe.name then
				force.recipes[recipe.name].enabled = false
				force.recipes[recipe.name.."-done"].enabled = true
			end
			player.print{"message.space-elevator-already-done",phase.name,phase.localised_name}
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
			gui.set_enabled(player, ready)
		end
	end
end

local function updateAllPlayers()
	for _,p in pairs(game.players) do
		updateElevator(p)
	end
end

---@param player LuaPlayer
---@param entity LuaEntity
gui.callbacks.submit = function(player, entity)
	if not (entity and entity.valid) then return end
	local recipe = entity.get_recipe()
	if not recipe then return end
	local force = player.force

	local phase = recipe.products[1].name
	if force.technologies[phase].researched then return end
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

	force.technologies[phase].researched = true
	force.play_sound{path="utility/research_completed"}

	getitems.assembler(entity, player.get_main_inventory())
	entity.set_recipe(nil)
end

---@param event on_research_finished
local function onResearch(event)
	if string.starts_with(event.research.name, "space-elevator-") then
		completeElevator(event.research)
	end
end
---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if entity.name ~= elevator then return end
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
		gui.open_gui(player, entity)
		updateElevator(player)
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.space_elevator = global.space_elevator or script_data
		global.debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		script_data = global.space_elevator or script_data
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_nth_tick = {
		[6] = updateAllPlayers,
	},
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_research_finished] = onResearch,
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
