local bev = require(modpath.."scripts.lualib.build-events")
local powertrip = require(modpath.."scripts.lualib.power-trip")

local burner = "biomass-burner"
local burner_hub = "biomass-burner-hub"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == burner or entity.name == burner_hub then
		powertrip.registerGenerator(entity, entity, entity.name.."-buffer")
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt
}
