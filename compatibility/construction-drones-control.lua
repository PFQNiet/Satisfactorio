local function setup()
	if game.active_mods['Construction_Drones'] then
		require(modpath.."constants/sink-tradein")[require("__"..mod.."__.shared").units.construction_drone] = 1000
	end
end

return {
	onInit = setup,
	onLoad = setup
}
