return {
	require(modpath.."scripts.gameplay.build-gun"), -- must be early in event handlers so it can invalidate builds
	require(modpath.."scripts.gameplay.recipe-browser"),
	require(modpath.."scripts.gameplay.to-do-list"), -- should be early in event handlers so it can handle insta-swapped entities
	require(modpath.."scripts.gameplay.indestructible"),
	require(modpath.."scripts.gameplay.resource-scanner"),
	require(modpath.."scripts.gameplay.radioactivity"),
	require(modpath.."scripts.gameplay.character-healing"),
	require(modpath.."scripts.gameplay.corpse-scanner"),
	require(modpath.."scripts.gameplay.inventory-sort-and-trash"),
	require(modpath.."scripts.gameplay.tech-extras"),
	require(modpath.."scripts.gameplay.map-tweaks"),
	require(modpath.."scripts.gameplay.self-driving")
}
