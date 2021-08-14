local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local splitter = "conveyor-splitter"
local buffer = "merger-splitter-box"

---@param entity LuaEntity
local function onBuilt(entity)
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

	io.addConnection(entity, {0,-1}, "output", box)
	io.addConnection(entity, {-1,0}, "output", box, defines.direction.west)
	io.addConnection(entity, {1,0}, "output", box, defines.direction.east)
	entity.operable = false
	entity.rotatable = false
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=splitter}
	}
}
