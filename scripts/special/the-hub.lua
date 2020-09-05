local hub = require("scripts/lualib/the-hub")

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == hub.name then
		hub.buildFloor(entity)
		hub.buildTerminal(entity)
		hub.buildCraftBench(entity)
		if global['hub-completed'] and global['hub-completed'][entity.force.name] and global['hub-completed'][entity.force.name]['hub-tier0-hub-upgrade-1'] then
			hub.buildStorageChest(entity)
		end
		-- remove base item
		entity.destroy()
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == hub.terminal then
		hub.removeCraftBench(entity, event and event.buffer or nil)
		hub.removeStorageChest(entity, event and event.buffer or nil)
		hub.removeGraphic(entity)
		-- remove terminal entity from global list
		global['hub-terminal'][entity.force.name] = nil
	end
end

local function onInit()
	global['hub-terminal'] = {} -- dictionary Force.name -> {surface, position} of the Terminal
	global['hub-completed'] = {} -- dictionary Force.name -> list of completed milestones
	-- TODO if a new force is added, it too should benefit from the default research
	game.forces.player.technologies['the-hub'].researched = true
end
return {
	on_init = onInit,
	on_nth_tick = {
		[300] = hub.updateMilestoneGUI
	},
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved
	}
}
