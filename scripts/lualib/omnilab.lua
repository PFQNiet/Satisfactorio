-- uses global['omnilab'] as table of Force index -> {surface, position} of the lab (although it'll always be {navis, {0,0}} so really it's just flagging it exists)
local lab = "omnilab"

local function setupOmnilab(force)
	-- build a hidden Lab that secretly receives all of the HUB, Space Elevator and MAM upgrade items
	-- also sets the base "HUB research" to completed
	if not global['omnilab'] then global['omnilab'] = {} end
	if global['omnilab'][force.index] then return end
	local omnilab = game.surfaces.nauvis.create_entity{
		name = lab,
		position = {0,0},
		force = force,
		raise_built = true
	}
	omnilab.operable = false
	omnilab.minable = false
	omnilab.destructible = false
	global[lab][force.index] = {omnilab.surface.index, omnilab.position}
	force.research_queue = {"the-hub"}
	force.technologies['the-hub'].researched = true
	force.play_sound{path="utility/research_completed"}
	return omnilab
end
local function getOmnilab(force)
	if not global['omnilab'] then return nil end
	local pointer = global['omnilab'][force.index]
	if not pointer then return nil end
	return game.surfaces[pointer[1]].find_entity(lab,pointer[2])
end

return {
	setupOmnilab = setupOmnilab,
	getOmnilab = getOmnilab
}
