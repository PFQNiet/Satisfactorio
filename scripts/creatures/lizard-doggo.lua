-- Lizard Doggo - tameable entity
-- By default it wanders, but it will flee from players that come too close
-- If a Paleberry is on the ground nearby, it will instead go to it and eat one from the item stack, becoming tamed
-- Once tamed it will follow its owner and gains a GUI. The GUI sometimes gives a free item, and can also be used to give a "stay" command
-- If a tamed doggo gets too far from its owner it will go back to wandering but will be on the lookout for its owner to follow them again

-- uses global.small_biter.lizard-doggos to track all of this, indexed by unit_number
-- uses global.small_biter.dropped-bait to track dropped berries, as they sadly lack a "last_user"

local bev = require(modpath.."scripts.lualib.build-events")
local loot = require(modpath.."constants.doggo-loot")
local gui = require(modpath.."scripts.gui.lizard-doggo")

local doggo = "lizard-doggo"
local bait = "paleberry"

---@class BaitData
---@field entity LuaEntity ItemOnGround
---@field player LuaPlayer

---@class DoggoData
---@field entity LuaEntity Unit
---@field owner LuaPlayer|nil No owner = wild
---@field itemtimer uint Tick at which the next item will be generated
---@field helditem DoggoLoot|nil Found loot

---@class DoggoLoot
---@field name string
---@field localised_name LocalisedString
---@field count uint8

---@class global.pets
---@field lizard_doggos table<uint, DoggoData> Indexed by unit number of the doggo
---@field dropped_bait table<uint64, BaitData> Entity destroyed reg number => bait information
local script_data = {
	lizard_doggos = {},
	dropped_bait = {}
}

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == doggo then
		script_data.lizard_doggos[entity.unit_number] = {
			entity = entity,
			owner = nil, -- no owner = wild
			itemtimer = nil,
			helditem = nil
		}
		entity.set_command{
			type = defines.command.wander,
			radius = 20,
			ticks_to_wait = 180,
			distraction = defines.distraction.none
		}
	end
end

---@param event on_player_dropped_item
local function onDroppedItem(event)
	if event.entity.stack.name == bait then
		local reg = script.register_on_entity_destroyed(event.entity)
		script_data.dropped_bait[reg] = {
			entity = event.entity,
			player = game.players[event.player_index]
		}
	end
end

---@param event on_entity_destroyed
local function onEntityDestroyed(event)
	if script_data.dropped_bait[event.registration_number] then
		script_data.dropped_bait[event.registration_number] = nil
	end
end

---@param event on_entity_died
local function onEntityDied(event)
	if event.entity.valid and event.entity.name == doggo then
		local doggos = script_data.lizard_doggos
		local data = doggos[event.entity.unit_number]
		local item = data and data.helditem
		if item then
			event.entity.surface.spill_item_stack(
				event.entity.position,
				item,
				true, nil, false
			)
		end
		gui.close_all_gui(data)
		doggos[event.entity.unit_number] = nil
	end
end

---@param struct DoggoData
local function generateDoggoLoot(struct)
	local rand = math.random()*100
	for name,entry in pairs(loot) do
		rand = rand - entry.probability
		if rand < 0 then
			struct.helditem = {
				name = name,
				localised_name = game.item_prototypes[name].localised_name,
				count = math.random(entry.amount_min, entry.amount_max)
			}
			return
		end
	end
end

---@param struct DoggoData
local function setupNextDoggoLoot(struct)
	struct.helditem = nil
	struct.itemtimer = game.tick + math.random(8*60*60,15*60*60) -- 8-15 minutes
end

--#region Doggo AI

-- Look for a Paleberry and return it if found
---@param unit LuaEntity Unit
---@return BaitData|nil
local function lookForFood(unit)
	local itemsonground = unit.surface.find_entities_filtered{
		type = "item-entity",
		position = unit.position,
		radius = 15
	}
	for _,item in pairs(itemsonground) do
		if item.valid and item.stack.valid_for_read and item.stack.name == bait then
			-- ensure berry item is in dropped bait list, so it's assigned to a player
			for _,entry in pairs(script_data.dropped_bait) do
				if entry.entity == item then
					return entry
				end
			end
		end
	end
end

-- Go to the Paleberry if needed, and eat it once close enough
---@param struct DoggoData
---@param berry BaitData
local function eatFood(struct, berry)
	local unit = struct.entity
	local mypos = unit.position
	local target = berry.entity
	local position = target.position
	local dist = (position.x-mypos.x)^2 + (position.y-mypos.y)^2
	if dist > 3*3 then
		-- go to the berry
		unit.set_command{
			type = defines.command.go_to_location,
			destination_entity = target,
			radius = 2,
			distraction = defines.distraction.none
		}
	else
		-- eat the berry and become tamed by whoever placed it
		struct.owner = berry.player
		setupNextDoggoLoot(struct)
		if target.stack.count == 1 then
			target.destroy()
		else
			target.stack.count = target.stack.count - 1
		end
		unit.set_command{
			type = defines.command.stop,
			ticks_to_wait = 60,
			distraction = defines.distraction.none
		}
	end
end

-- Find any nearby character to flee from
---@param unit LuaEntity Unit
---@return LuaEntity|nil
local function findNearbyCharacter(unit)
	return unit.surface.find_entities_filtered{
		type = "character",
		position = unit.position,
		radius = 10,
		limit = 1
	}[1]
end

---@param unit LuaEntity Unit
---@param character LuaEntity Character
local function runAwayFrom(unit, character)
	unit.set_command{
		type = defines.command.flee,
		from = character,
		distraction = defines.distraction.none
	}
end
---@param unit LuaEntity Unit
local function wanderFreely(unit)
	unit.set_command{
		type = defines.command.wander,
		radius = 20,
		ticks_to_wait = 180,
		distraction = defines.distraction.none
	}
end

-- Returns distance^2 between the doggo and its owner
---@param struct DoggoData
---@return number
local function howFarIsMyOwner(struct)
	local mypos = struct.entity.position
	local ownerpos = struct.owner.position
	return (ownerpos.x-mypos.x)^2 + (ownerpos.y-mypos.y)^2
end

---@param unit LuaEntity Unit
---@param time uint Ticks to wait
local function stayPut(unit, time)
	unit.set_command{
		type = defines.command.stop,
		ticks_to_wait = time,
		distraction = defines.distraction.none
	}
end

---@param unit LuaEntity Unit
---@param owner LuaPlayer
local function followOwner(unit, owner)
	unit.set_command{
		type = defines.command.go_to_location,
		destination = owner.position,
		radius = 3,
		distraction = defines.distraction.none
	}
end

---@param event on_ai_command_completed
local function onCommandCompleted(event)
	local struct = script_data.lizard_doggos[event.unit_number]
	if struct then
		if struct.entity.valid then
			if not struct.owner then
				local berry = lookForFood(struct.entity)
				if berry then
					eatFood(struct, berry)
				else
					local character = findNearbyCharacter(struct.entity)
					if character then
						runAwayFrom(struct.entity, character)
					else
						wanderFreely(struct.entity)
					end
				end
			else
				local dist = howFarIsMyOwner(struct)
				if dist < 5*5 then
					stayPut(struct.entity, 60)
				elseif dist < 20*20 then
					followOwner(struct.entity, struct.owner)
				else
					wanderFreely(struct.entity)
				end
			end
		else
			-- died perhaps, clean up the struct
			script_data.lizard_doggos[event.unit_number] = nil
		end
	end
end
--#endregion

local function onInteract(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.valid and player.selected.name == doggo then
		if player.can_reach_entity(player.selected) then
			local struct = script_data.lizard_doggos[player.selected.unit_number]
			if struct and struct.owner and struct.owner.force == player.force then
				gui.open_gui(player, struct)
			end
		else
			player.create_local_flying_text{
				text = {"cant-reach"},
				create_at_cursor = true
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
		end
	end
end

---@param player LuaPlayer
---@param struct DoggoData
gui.callbacks.fast_take_loot = function(player, struct)
	local helditem = struct.helditem
	if not helditem then return end
	local inserted = player.insert(helditem)
	if inserted == helditem.count then
		setupNextDoggoLoot(struct)
	else
		helditem.count = helditem.count - inserted
	end
end

---@param player LuaPlayer
---@param struct DoggoData
gui.callbacks.take_loot = function(player, struct)
	local helditem = struct.helditem
	if not helditem then return end
	if player.cursor_stack.valid_for_read then return end
	player.cursor_stack.set_stack(helditem)
	setupNextDoggoLoot(struct)
end

---@param struct DoggoData
gui.callbacks.stay = function(struct)
	if not struct.entity.valid then return end
	stayPut(struct.entity, 30*60)
end

local function everyFiveSeconds()
	for _,struct in pairs(script_data.lizard_doggos) do
		if struct.owner and not struct.helditem and struct.itemtimer < game.tick then
			generateDoggoLoot(struct)
		end
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	on_init = function()
		global.pets = global.pets or script_data
	end,
	on_load = function()
		script_data = global.pets or script_data
	end,
	on_nth_tick = {
		[300] = everyFiveSeconds
	},
	events = {
		[defines.events.on_player_dropped_item] = onDroppedItem,
		[defines.events.on_entity_destroyed] = onEntityDestroyed,

		[defines.events.on_entity_died] = onEntityDied,
		[defines.events.on_ai_command_completed] = onCommandCompleted,
		["interact"] = onInteract
	}
}
