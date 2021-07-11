-- uses global.space_elevator.elevator as table of Force index -> elevator
-- uses global.space-elevator.phase as table of Player index -> phase shown in GUI - if different to current selection then GUI needs refresh, otherwise just update counts
-- uses global.player_build_error_debounce to track force -> last error tick to de-duplicate placement errors
local string = require(modpath.."scripts.lualib.string")
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local refundEntity = require(modpath.."scripts.lualib.building-management").refundEntity
local link = require(modpath.."scripts.lualib.linked-entity")

local elevator = "space-elevator"

---@class SpaceElevator
---@field elevator LuaEntity
---@field silo LuaEntity
---@field inserter LuaEntity

---@class global.space_elevator
---@field elevator table<uint, SpaceElevator> Force ID => Elevator
---@field phase table<uint, string> Player ID => Last shown phase in GUI
local script_data = {
	elevator = {},
	phase = {}
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
		technology.force.print({"",message,{"message.hub-new-tiers-available"}})
	end
	launchFreighter(findElevatorForForce(technology.force), technology.research_unit_ingredients[1].name)
end
---@param force LuaForce
local function updateElevatorGUI(force)
	local struct = findElevatorForForce(force)
	if not struct then return end
	local hub = struct.elevator
	local phase = {name="none"}
	local recipe
	local submitted
	-- if an elevator exists for this force, check its recipe and inventory
	if hub and hub.valid then
		recipe = hub.get_recipe()
		if recipe then
			phase = game.item_prototypes[recipe.products[1].name]
			if force.technologies[phase.name].researched then
				-- phase already completed, so reject it
				local spill = hub.set_recipe(nil)
				for name,count in pairs(spill) do
					hub.surface.spill_item_stack(
						hub.position,
						{
							name = name,
							count = count,
						},
						true, force, false
					)
				end
				if phase.name == recipe.name then
					force.recipes[recipe.name].enabled = false
					force.recipes[recipe.name.."-done"].enabled = true
				end
				force.print({"message.space-elevator-already-done",phase.name,phase.localised_name})
				phase = {name="none"}
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

	for _,player in pairs(force.players) do
		local gui = player.gui.relative
		local flow = gui['space-elevator']
		if not flow then
			flow = gui.add{
				type = "flow",
				name = "space-elevator",
				anchor = {
					gui = defines.relative_gui_type.assembling_machine_gui,
					position = defines.relative_gui_position.bottom,
					name = elevator
				},
				direction = "horizontal"
			}
			flow.add{type="empty-widget", style="filler_widget"}
			local frame = flow.add{
				type = "frame",
				name = "space-elevator-frame",
				direction = "horizontal",
				style = "frame_with_even_paddings"
			}
			frame.add{
				type = "button",
				style = "submit_button",
				name = "space-elevator-submit",
				caption = {"gui.space-elevator-submit-caption"}
			}
			script_data.phase[player.index] = nil -- force gui refresh
		end

		-- gather up GUI element references
		local frame = flow['space-elevator-frame']
		local button = frame['space-elevator-submit']

		-- so now we've established the GUI exists, and is populated with a table for the currently selected phase... if there is one, update the counts now
		local ready = true
		if phase.name ~= "none" then
			for _,ingredient in ipairs(recipe.ingredients) do
				if (submitted[ingredient.name] or 0) < ingredient.amount then
					ready = false
					break
				end
			end
			button.enabled = ready
		end
	end
end
---@param force LuaForce
---@param player LuaPlayer
local function submitElevator(force, player)
	local hub = findElevatorForForce(force).elevator
	if not hub or not hub.valid then return end
	local recipe = hub.get_recipe()
	if not recipe then return end
	local phase = recipe.products[1].name
	if force.technologies[phase].researched then return end
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
	force.technologies[phase].researched = true
	force.play_sound{path="utility/research_completed"}
	for name,count in pairs(inventory.get_contents()) do
		if player then
			count = count - player.insert{name=name,count=count}
		end
		if count > 0 then
			(player or hub).surface.spill_item_stack(
				(player or hub).position,
				{name = name, count = count},
				true, force, false
			)
		end
	end
	hub.set_recipe(nil)
end

local function on10thTick()
	for _,force in pairs(game.forces) do
		updateElevatorGUI(force)
	end
end
---@param event on_research_finished
local function onResearch(event)
	if string.starts_with(event.research.name, "space-elevator-") then
		completeElevator(event.research)
	end
end
---@param event on_gui_opened
local function onGuiOpened(event)
	if event.entity and event.entity.name == elevator then
		local force = event.entity.force
		if event.entity.get_recipe() == nil then
			-- double-check for, and disable, any recipes that have completed technologies
			for _,recipe in pairs(force.recipes) do
				if force.technologies[recipe.name] and force.recipes[recipe.name.."-done"] and force.technologies[recipe.name].researched then
					force.recipes[recipe.name].enabled = false
					force.recipes[recipe.name.."-done"].enabled = true
				end
			end
		else
			updateElevatorGUI(force)
		end
	end
end
---@param event on_gui_click
local function onGuiClick(event)
	if event.element and event.element.valid and event.element.name == "space-elevator-submit" then
		local player = game.players[event.player_index]
		submitElevator(player.force, player)
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
		[6] = on10thTick,
	},
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_research_finished] = onResearch,
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_click] = onGuiClick
	}
}
