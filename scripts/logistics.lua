return {
	require(modpath.."scripts.logistics.conveyor-belts"),
	require(modpath.."scripts.logistics.conveyor-merger"),
	require(modpath.."scripts.logistics.conveyor-splitter"),
	require(modpath.."scripts.logistics.splitters").lib, -- manages both smart and programmable splitters
	require(modpath.."scripts.logistics.smart-splitter"),
	require(modpath.."scripts.logistics.programmable-splitter"),
	require(modpath.."scripts.logistics.valve"),
	require(modpath.."scripts.logistics.foundation"),
	require(modpath.."scripts.logistics.jump-pads"),
	require(modpath.."scripts.logistics.hyper-tubes"),
	require(modpath.."scripts.logistics.pipe-flow")
}
