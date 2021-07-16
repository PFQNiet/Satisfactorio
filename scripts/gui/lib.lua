return {
	{
		on_init = function()
			if not global.gui then global.gui = {} end
		end
	},
	require(modpath.."scripts.gui.build-gun").lib,
	require(modpath.."scripts.gui.resource-scanner").lib,
	require(modpath.."scripts.gui.recipe-browser").lib,
	require(modpath.."scripts.gui.to-do-list").lib,
	require(modpath.."scripts.gui.trash-slot").lib,
	require(modpath.."scripts.gui.fuse-box").lib,
	require(modpath.."scripts.gui.sort-container").lib,
	require(modpath.."scripts.gui.map-marker").lib,
	require(modpath.."scripts.gui.pipe-flow").lib,
	require(modpath.."scripts.gui.valve").lib,
	require(modpath.."scripts.gui.radioactivity").lib,
	require(modpath.."scripts.gui.lizard-doggo").lib,
	require(modpath.."scripts.gui.self-driving").lib,
	require(modpath.."scripts.gui.crash-sites").lib
}
