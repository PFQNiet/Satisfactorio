-- uses global.space_elevator.elevator as table of Force index -> elevator
-- uses global.space-elevator.phase as table of Force index -> phase shown in GUI - if different to current selection then GUI needs refresh, otherwise just update counts
-- uses global.player_build_error_debounce'] to track force -> last error tick to de-duplicate placement errors
local util = require("util")
local string = require("scripts.lualib.string")
local io = require("scripts.lualib.input-output")

local elevator = "space-elevator"

local script_data = {
	elevator = {},
	phase = {}
}
local debounce_error = {}

local function findElevatorForForce(force)
	return script_data.elevator[force.index]
end

local function refundEntity(entity, reason, event)
	-- refund the entity and trigger an error message flying text (but only if event.tick is not too recent from the last one)
	local player = entity.last_user
	if player then
		if not player.cursor_stack.valid_for_read then
			player.cursor_stack.set_stack{name=entity.name,count=1}
		else
			player.insert{name=entity.name,count=1}
		end
		if not debounce_error[player.force.index] or debounce_error[player.force.index] < event.tick then
			player.surface.create_entity{
				name = "flying-text",
				position = entity.position,
				text = reason,
				render_player_index = player.index
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
			debounce_error[player.force.index] = event.tick + 60
		end
	else
		entity.surface.spill_item_stack(entity.position, {name=entity.name,count=1}, false, nil, false)
	end
	entity.destroy()
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == elevator then
		if findElevatorForForce(entity.force) then
			refundEntity(entity, {"message.space-elevator-only-one-allowed"}, event)
		else
			-- position hack to avoid it trying to drop stuff in the rocket silo
			io.addInput(entity, {-10,13}, {position={entity.position.x-8,entity.position.y}})
			io.addInput(entity, {-8,13}, {position={entity.position.x-8,entity.position.y}})
			io.addInput(entity, {-6,13}, {position={entity.position.x-8,entity.position.y}})
			io.addInput(entity, {-10,-13}, {position={entity.position.x-8,entity.position.y}}, defines.direction.south)
			io.addInput(entity, {-8,-13}, {position={entity.position.x-8,entity.position.y}}, defines.direction.south)
			io.addInput(entity, {-6,-13}, {position={entity.position.x-8,entity.position.y}}, defines.direction.south)
			local silo = entity.surface.create_entity{
				name = elevator.."-silo",
				position = entity.position,
				force = entity.force,
				raise_built = true
			}
			silo.operable = false
			silo.minable = false
			silo.destructible = false
			silo.auto_launch = true

			local inserter = silo.surface.create_entity{
				name = "loader-inserter",
				position = silo.position,
				force = silo.force,
				raise_built = true
			}
			inserter.drop_position = silo.position
			inserter.operable = false
			inserter.minable = false
			inserter.destructible = false

			script_data.elevator[entity.force.index] = entity
			entity.active = false
		end
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == elevator then
		io.remove(entity, event)
		local silo = entity.surface.find_entity(elevator.."-silo", entity.position)
		if not silo then
			game.print("Could not find Space Elevator silo")
		else
			silo.destroy()
		end
		local inserter = entity.surface.find_entity("loader-inserter", entity.position)
		if not silo then
			game.print("Could not find Space Elevator inserter")
		else
			inserter.destroy()
			silo.destroy()
		end
		script_data.elevator[entity.force.index] = nil
	end
end

local function launchFreighter(hub, item)
	if not hub then return end
	local silo = hub.surface.find_entity(elevator.."-silo",hub.position)
	if not (silo and silo.valid) then
		game.print("Could not find Freighter")
		return
	end
	local inserter = hub.surface.find_entity("loader-inserter",hub.position)
	if not (inserter and inserter.valid) then
		game.print("Could not find Freighter Loader")
		return
	end
	inserter.held_stack.set_stack({name=item, count=1})
	silo.rocket_parts = 1
end

local function completeElevator(technology)
	if string.starts_with(technology.name, "space-elevator") then
		local message = {"message.space-elevator-complete",technology.name,technology.localised_name}
		technology.force.print(message)
		launchFreighter(findElevatorForForce(technology.force), technology.research_unit_ingredients[1].name)
	end
end
local function updateElevatorGUI(force)
	if not force then
		for _,force in pairs(game.forces) do
			updateElevatorGUI(force)
		end
		return
	end

	local hub = findElevatorForForce(force)
	local phase = {name="none"}
	local recipe
	local submitted
	-- if an elevator exists for this force, check its recipe and inventory
	if hub and hub.valid then
		recipe = hub.get_recipe()
		if recipe then
			phase = game.item_prototypes[recipe.products[1].name]
			if force.technologies[phase.name].reserached then
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
		local frame = gui['space-elevator-tracking']
		-- if the space elevator was deconstructed, hide the GUI
		if not findElevatorForForce(force) then
			if frame then
				frame.destroy()
			end
		else
			-- create the GUI if it doesn't exist
			if not frame then
				frame = gui.add{
					type = "frame",
					name = "space-elevator-tracking",
					direction = "vertical",
					caption = {"gui.space-elevator-tracking-caption"},
					style = "inner_frame_in_outer_frame"
				}
				frame.style.horizontally_stretchable = false
				frame.style.use_header_filler = false
				frame.add{
					type = "label",
					name = "space-elevator-tracking-name",
					caption = {"","[font=heading-2]",{"gui.space-elevator-tracking-none-selected"},"[/font]"}
				}
				local inner = frame.add{
					type = "frame",
					name = "space-elevator-tracking-content",
					style = "inside_shallow_frame",
					direction = "vertical"
				}
				inner.style.horizontally_stretchable = true
				inner.style.top_margin = 4
				inner.style.bottom_margin = 4
				inner.add{
					type = "table",
					name = "space-elevator-tracking-table",
					style = "bordered_table",
					column_count = 3
				}
				local bottom = frame.add{
					type = "flow",
					name = "space-elevator-tracking-bottom"
				}
				local pusher = bottom.add{type="empty-widget"}
				pusher.style.horizontally_stretchable = true
				bottom.add{
					type = "button",
					style = "confirm_button",
					name = "space-elevator-tracking-submit",
					caption = {"gui.space-elevator-submit-caption"}
				}
			end

			-- gather up GUI element references
			local name = frame['space-elevator-tracking-name']
			local inner = frame['space-elevator-tracking-content']
			local table = inner['space-elevator-tracking-table']
			local bottom = frame['space-elevator-tracking-bottom']
			local button = bottom['space-elevator-tracking-submit']

			-- check if the selected milestone has been changed
			if phase.name ~= script_data.phase[force.index] then
				script_data.phase[force.index] = phase.name
				inner.visible = phase.name ~= "none"
				bottom.visible = inner.visible
				button.enabled = false
				table.clear()
				if phase.name == "none" then
					name.caption = {"","[font=heading-2]",{"gui.space-elevator-tracking-none-selected"},"[/font]"}
					frame.visible = false
				else
					frame.visible = true
					-- if milestone is actually set then we know this is valid
					name.caption = {"","[img=recipe/"..phase.name.."] [font=heading-2]",phase.localised_name,"[/font]"}
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
							name = "space-elevator-tracking-ingredient-"..ingredient.name
						}
						local pusher = count_flow.add{type="empty-widget"}
						pusher.style.horizontally_stretchable = true
						count_flow.add{
							type = "label",
							name = "space-elevator-tracking-ingredient-"..ingredient.name.."-count",
							caption = {"gui.fraction", -1, -1} -- unset by default, will be populated in the next block
						}
					end
				end
			end

			-- so now we've established the GUI exists, and is populated with a table for the currently selected phase... if there is one, update the counts now
			local ready = true
			if phase.name ~= "none" then
				frame.visible = true
				for _,ingredient in ipairs(recipe.ingredients) do
					local label = table['space-elevator-tracking-ingredient-'..ingredient.name]['space-elevator-tracking-ingredient-'..ingredient.name..'-count']
					label.caption = {"gui.fraction", util.format_number(submitted[ingredient.name] or 0), util.format_number(ingredient.amount)}
					if (submitted[ingredient.name] or 0) < ingredient.amount then
						ready = false
					end
				end
				button.visible = player.opened and player.opened == hub
				button.enabled = ready
			else
				frame.visible = false
			end
		end
	end
end
local function submitElevator(force)
	local hub = findElevatorForForce(force)
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

local function onTick(event)
	updateElevatorGUI()
end
local function onResearch(event)
	-- can just pass all researches to the function, since that already checks if it's an elevator tech.
	completeElevator(event.research)
end
local function onGuiClick(event)
	if event.element.name == "space-elevator-tracking-submit" then
		submitElevator(game.players[event.player_index].force)
	end
end

return {
	on_init = function()
		global.space_elevator = global.space_elevator or script_data
		global.debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_load = function()
		script_data = global.space_elevator or script_data
		debounce_error = global.player_build_error_debounce or debounce_error
	end,
	on_configuration_changed = function()
		if not global.space_elevator then
			global.space_elevator = script_data
		end
		if not global.player_build_error_debounce then
			global.player_build_error_debounce = debounce_error
		end
		if global['space-elevator'] then
			global.space_elevator.elevator = table.deepcopy(global['space-elevator'])
			global['space-elevator'] = nil
		end

		if global['space-elevator-phase'] then
			global.space_elevator.phase = table.deepcopy(global['space-elevator-phase'])
			global['space-elevator-phase'] = nil
		end

		if global['player-build-error-debounce'] then
			global.player_build_error_debounce = table.deepcopy(global['player-debounce-error-debounce'])
			debounce_error = global.player_build_error_debounce
			global['player-debounce-error-debounce'] = nil
		end
	end,
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
