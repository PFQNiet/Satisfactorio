-- a splitter that allows setting up to 64 filters among outputs
local control = require(modpath.."scripts.logistics.splitters")
local gui = require(modpath.."scripts.gui.programmable-splitter")
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local splitter = "programmable-splitter"
local buffer = "merger-splitter-box"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == splitter then
		local box = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		link.register(entity, box)

		local conn = io.addConnection(entity, {0,1}, "input", box)
		-- connect inserters to buffer and only enable if item count = 0
		for _,inserter in pairs{conn.inserter_left, conn.inserter_right} do
			inserter.connect_neighbour{
				wire = defines.wire_type.red,
				target_entity = box
			}
			inserter.get_or_create_control_behavior().circuit_condition = {
				condition = {
					first_signal = {
						type="virtual", name="signal-everything"
					},
					comparator = "=",
					constant = 0
				}
			}
		end

		local forward = io.addConnection(entity, {0,-1}, "output", box)
		local left = io.addConnection(entity, {-1,0}, "output", box, defines.direction.west)
		local right = io.addConnection(entity, {1,0}, "output", box, defines.direction.east)

		entity.rotatable = false
		
		control.create(entity, box, {
			left = left,
			forward = forward,
			right = right
		})
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == splitter then
		gui.open_gui(player, control.get(event.entity))
	end
end

---@param player LuaPlayer
---@param struct SmartSplitterData
gui.callbacks.update = function(player, struct)
	control.refresh(struct)
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
