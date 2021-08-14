---@alias on_build on_built_entity|on_robot_built_entity|script_raised_built|script_raised_revive
---@alias on_destroy on_player_mined_entity|on_robot_mined_entity|on_entity_died|script_raised_destroy

---@class applyBuildEvents_filter
---@field type string|string[]
---@field name string|string[]
---@field callback fun(entity:LuaEntity):boolean

---@class applyBuildEvents_onbuild
---@field callback fun(entity:LuaEntity)
---@field filter applyBuildEvents_filter

---@class applyBuildEvents_ondestroy
---@field callback fun(entity:LuaEntity, buffer:LuaInventory, player:LuaPlayer)
---@field filter applyBuildEvents_filter

---@class applyBuildEvents_param
---@field on_build applyBuildEvents_onbuild
---@field on_destroy applyBuildEvents_ondestroy

local build_events_by_name = {}
local build_events_by_type = {}
local build_events_by_callback = {}

local destroy_events_by_name = {}
local destroy_events_by_type = {}
local destroy_events_by_callback = {}

---@param lib applyBuildEvents_param
---@return table
local function applyBuildEvents(lib)
	if lib.on_build then
		local handler = lib.on_build.callback
		local filter = lib.on_build.filter or {callback=function() return true end}
		local name = filter.name
		if name then
			if type(name) == "string" then name = {name} end
			for _,n in pairs(name) do
				if not build_events_by_name[n] then build_events_by_name[n] = {} end
				table.insert(build_events_by_name[n], handler)
			end
		end

		local entity_type = filter.type
		if entity_type then
			if type(entity_type) == "string" then entity_type = {entity_type} end
			for _,t in pairs(entity_type) do
				if not build_events_by_type[t] then build_events_by_type[t] = {} end
				table.insert(build_events_by_type[t], handler)
			end
		end

		local callback = filter.callback
		if callback then
			table.insert(build_events_by_callback, {test = callback, handler = handler})
		end
		lib.on_build = nil
	end

	if lib.on_destroy then
		local handler = lib.on_destroy.callback
		local filter = lib.on_destroy.filter or {callback=function() return true end}
		local name = filter.name
		if name then
			if type(name) == "string" then name = {name} end
			for _,n in pairs(name) do
				if not destroy_events_by_name[n] then destroy_events_by_name[n] = {} end
				table.insert(destroy_events_by_name[n], handler)
			end
		end

		local entity_type = filter.type
		if entity_type then
			if type(entity_type) == "string" then entity_type = {entity_type} end
			for _,t in pairs(entity_type) do
				if not destroy_events_by_type[t] then destroy_events_by_type[t] = {} end
				table.insert(destroy_events_by_type[t], handler)
			end
		end

		local callback = filter.callback
		if callback then
			table.insert(destroy_events_by_callback, {test = callback, handler = handler})
		end
		lib.on_destroy = nil
	end

	return lib
end

---@param event on_build
local function buildEvent(event)
	---@type LuaEntity
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if build_events_by_name[entity.name] then
		for _,handler in pairs(build_events_by_name[entity.name]) do
			handler(entity)
			if not entity.valid then return end
		end
	end
	if build_events_by_type[entity.type] then
		for _,handler in pairs(build_events_by_type[entity.type]) do
			handler(entity)
			if not entity.valid then return end
		end
	end
	for _,pair in pairs(build_events_by_callback) do
		if pair.test(entity) then
			pair.handler(entity)
			if not entity.valid then return end
		end
	end
end

---@param event on_destroy
local function destroyEvent(event)
	local entity = event.entity
	local player = event.player_index and game.players[event.player_index]
	if not (entity and entity.valid) then return end
	if destroy_events_by_name[entity.name] then
		for _,handler in pairs(destroy_events_by_name[entity.name]) do
			handler(entity, event.buffer, player)
			if not entity.valid then return end
		end
	end
	if destroy_events_by_type[entity.type] then
		for _,handler in pairs(destroy_events_by_type[entity.type]) do
			handler(entity, event.buffer, player)
			if not entity.valid then return end
		end
	end
	for _,pair in pairs(destroy_events_by_callback) do
		if pair.test(entity) then
			pair.handler(entity, event.buffer, player)
			if not entity.valid then return end
		end
	end
end

return {
	applyBuildEvents = applyBuildEvents,
	lib = {
		events = {
			[defines.events.on_built_entity] = buildEvent,
			[defines.events.on_robot_built_entity] = buildEvent,
			[defines.events.script_raised_built] = buildEvent,
			[defines.events.script_raised_revive] = buildEvent,

			[defines.events.on_player_mined_entity] = destroyEvent,
			[defines.events.on_robot_mined_entity] = destroyEvent,
			[defines.events.on_entity_died] = destroyEvent,
			[defines.events.script_raised_destroy] = destroyEvent
		}
	}
}
