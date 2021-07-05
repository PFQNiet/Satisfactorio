-- link an entity such that when the parent is removed, the child entity(-ies) are also removed
-- uses global.linked_entities to track them
local bev = require(modpath.."scripts.lualib.build-events")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local script_data = {}

---@param parent LuaEntity
local function getRegistration(parent)
	return script_data[parent.unit_number]
end
---@param parent LuaEntity
---@return LuaEntity[]
local function getOrCreateRegistration(parent)
	local reg = getRegistration(parent)
	if reg then return reg end
	reg = {}
	script_data[parent.unit_number] = reg
	return reg
end
---@param parent LuaEntity
---@param child LuaEntity
local function registerLink(parent, child)
	table.insert(getOrCreateRegistration(parent), child)
end
---@param parent LuaEntity
---@param child LuaEntity
local function unregisterLink(parent, child)
	local reg = getRegistration(parent)
	if not reg then return end
	for i,test in pairs(reg) do
		if child == test then
			table.remove(reg, i)
			return
		end
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local reg = getRegistration(entity)
	if not reg then return end
	for _,child in pairs(reg) do
		if child.valid then
			if child.type == "burner-generator" then
				getitems.burner(child, event.buffer)
			elseif child.type == "assembling-machine" or child.type == "rocket-silo" then
				getitems.assembler(child, event.buffer)
			elseif child.type == "container" then
				getitems.storage(child, event.buffer)
			elseif child.type == "car" then
				getitems.car(child, event.buffer)
			elseif child.type == "spider-vehicle" then
				getitems.spider(child, event.buffer)
			elseif child.type == "inserter" then
				getitems.inserter(child, event.buffer)
			elseif child.type == "infinity-container" then
			elseif child.type == "simple-entity-with-owner" then
			elseif child.type == "electric-pole" then
			elseif child.type == "electric-energy-interface" then
			elseif child.type == "storage-tank" then
			elseif child.type == "mining-drill" then
			elseif child.type == "train-stop" then
			elseif child.type == "resource" then
				-- nothing to do here
			else
				error("Don't know how to get items from "..child.type)
			end
			child.destroy{raise_destroy=true}
		end
	end
	script_data[entity.unit_number] = nil
end

return {
	register = registerLink,
	unregister = unregisterLink,
	lib = bev.applyBuildEvents{
		on_init = function()
			global.linked_entities = global.linked_entities or script_data
		end,
		on_load = function()
			script_data = global.linked_entities or script_data
		end,
		on_destroy = onRemoved
	}
}
