local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local splitter = "conveyor-merger"
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

		local inputs = {
			{position={0,1}, direction=defines.direction.north},
			{position={1,0}, direction=defines.direction.west},
			{position={-1,0}, direction=defines.direction.east}
		}
		for _,pos in pairs(inputs) do
			local conn = io.addConnection(entity, pos.position, "input", box, pos.direction)
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
		end

		io.addConnection(entity, {0,-1}, "output", box)
		entity.operable = false
		entity.rotatable = false
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
