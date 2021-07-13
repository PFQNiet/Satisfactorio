return {
	{
		on_init = function()
			if not global.gui then global.gui = {} end
		end
	},
	require(modpath.."scripts.gui.lizard-doggo").lib
}
