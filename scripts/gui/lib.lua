return {
	{
		on_init = function()
			if not global.gui then global.gui = {} end
		end
	},
	require(modpath.."scripts.gui.build-gun").lib,
	require(modpath.."scripts.gui.resource-scanner").lib,
	require(modpath.."scripts.gui.object-scanner").lib,
	require(modpath.."scripts.gui.beacon-scanner").lib,
	require(modpath.."scripts.gui.recipe-browser").lib,
	require(modpath.."scripts.gui.to-do-list").lib,
	require(modpath.."scripts.gui.trash-slot").lib,
	require(modpath.."scripts.gui.fuse-box").lib,
	require(modpath.."scripts.gui.sort-container").lib,
	require(modpath.."scripts.gui.the-hub-tracker").lib,
	require(modpath.."scripts.gui.the-hub-terminal").lib,
	require(modpath.."scripts.gui.space-elevator").lib,
	require(modpath.."scripts.gui.mam").lib,
	require(modpath.."scripts.gui.hard-drive").lib,
	require(modpath.."scripts.gui.smart-splitter").lib,
	require(modpath.."scripts.gui.programmable-splitter").lib,
	require(modpath.."scripts.gui.map-marker").lib,
	require(modpath.."scripts.gui.pipe-flow").lib,
	require(modpath.."scripts.gui.valve").lib,
	require(modpath.."scripts.gui.power-storage").lib,
	require(modpath.."scripts.gui.radioactivity").lib,
	require(modpath.."scripts.gui.lizard-doggo").lib,
	require(modpath.."scripts.gui.self-driving").lib,
	require(modpath.."scripts.gui.truck-station-tabs").lib,
	require(modpath.."scripts.gui.station-mode").lib,
	require(modpath.."scripts.gui.awesome-sink").lib,
	require(modpath.."scripts.gui.crash-sites").lib
}
