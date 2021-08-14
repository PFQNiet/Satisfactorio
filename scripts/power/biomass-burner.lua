local bev = require(modpath.."scripts.lualib.build-events")
local powertrip = require(modpath.."scripts.lualib.power-trip")

local burner = "biomass-burner"
local burner_hub = "biomass-burner-hub"

---@param entity LuaEntity
local function onBuilt(entity)
	powertrip.registerGenerator(entity, entity, entity.name.."-buffer")
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name={burner, burner_hub}}
	}
}
