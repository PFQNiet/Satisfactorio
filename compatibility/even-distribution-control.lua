if not script.active_mods['even-distribution'] then return {} end

local entities_to_ignore = {
	"merger-splitter-box",
	"miner-box"
}

local function applyExclusions()
	-- should only happen for menu sims (for some reason)
	if not remote.interfaces['even-distribution'] then return end

	for _,entity in pairs(entities_to_ignore) do
		remote.call("even-distribution", "add_ignored_entity", entity)
	end
end

return {
	on_init = applyExclusions,
	on_configuration_changed = applyExclusions
}
