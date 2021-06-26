local bev = require(modpath.."scripts.lualib.build-events")

local bench = "craft-bench"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == bench then
		entity.active = false
	end
end
local function onGuiOpened(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == bench then
		entity.active = true
	end
end
local function onGuiClosed(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == bench then
		-- check if another player has it open
		for _,p in pairs(game.players) do
			if p.opened and p.opened == entity then
				return
			end
		end
		entity.active = false
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed
	}
}
