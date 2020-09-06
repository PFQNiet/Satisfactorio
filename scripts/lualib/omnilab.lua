-- uses global['omnilab'] as table of Force name -> {surface, position} of the lab (although it'll always be {navis, {0,0}} so really it's just flagging it exists)
local lab = "omnilab"

local function setupOmnilab(force)
	-- build a hidden Lab that secretly receives all of the HUB, Space Elevator and MAM upgrade items
	-- also sets the base "HUB research" to completed
	if not global['omnilab'] then global['omnilab'] = {} end
	if global['omnilab'][force.name] then return end
	local omnilab = game.surfaces.nauvis.create_entity{
		name = lab,
		position = {0,0},
		force = force,
		raise_built = true
	}
	omnilab.operable = false
	omnilab.minable = false
	omnilab.destructible = false
	global[lab][force.name] = {omnilab.surface.name, omnilab.position}
	force.research_queue = {"the-hub"}
	force.technologies['the-hub'].researched = true
	force.play_sound{path="utility/research_completed"}
	return omnilab
end

return {
	setupOmnilab = setupOmnilab
}
