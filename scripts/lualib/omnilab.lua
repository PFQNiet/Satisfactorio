-- uses global.omnilab as table of Force index -> Omnilab
local lab = "omnilab"

local script_data = {}

local function setupOmnilab(force)
	-- build a hidden Lab that secretly receives all of MAM upgrade items
	if script_data[force.index] then return end
	local omnilab = game.surfaces.nauvis.create_entity{
		name = lab,
		position = {0,0},
		force = force,
		raise_built = true
	}
	omnilab.operable = false
	omnilab.minable = false
	omnilab.destructible = false
	script_data[force.index] = omnilab
	return omnilab
end
local function getOmnilab(force)
	return script_data[force.index]
end

return {
	setupOmnilab = setupOmnilab,
	getOmnilab = getOmnilab,
	on_init = function()
		global.omnilab = global.omnilab or script_data
	end,
	on_load = function()
		script_data = global.omnilab or script_data
	end
}
