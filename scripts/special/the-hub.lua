local hub = require("scripts.lualib.the-hub")

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == hub.name then
		hub.buildFloor(entity)
		hub.buildTerminal(entity)
		hub.buildCraftBench(entity)
		hub.buildStorageChest(entity)
		hub.buildBiomassBurner1(entity)
		hub.buildBiomassBurner2(entity)
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
		hub.removeBiomassBurner1(entity, event and event.buffer or nil)
		hub.removeBiomassBurner2(entity, event and event.buffer or nil)
		hub.removeFloor(entity)
	end
end

local function onTick(event)
	hub.updateMilestoneGUI()
end
local function onResearch(event)
	-- can just pass all researches to the HUB library, since that already checks if it's a HUB tech.
	hub.completeMilestone(event.research)
end
local function onGuiClick(event)
	if event.element.name == "hub-milestone-tracking-submit" then
		hub.submitMilestone(game.players[event.player_index].force)
	end
end

return {
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
