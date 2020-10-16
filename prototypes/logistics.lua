require("prototypes.logistics.loader-inserter")
require("prototypes.logistics.loader-conveyor")
require("prototypes.logistics.conveyor-belt-mk-1")
require("prototypes.logistics.conveyor-belt-mk-2")
require("prototypes.logistics.conveyor-belt-mk-3")
require("prototypes.logistics.conveyor-belt-mk-4")
require("prototypes.logistics.conveyor-belt-mk-5")
require("prototypes.logistics.conveyor-lift-mk-1")
require("prototypes.logistics.conveyor-lift-mk-2")
require("prototypes.logistics.conveyor-lift-mk-3")
require("prototypes.logistics.conveyor-lift-mk-4")
require("prototypes.logistics.conveyor-lift-mk-5")
require("prototypes.logistics.conveyor-merger")
require("prototypes.logistics.conveyor-splitter")
require("prototypes.logistics.smart-splitter")
require("prototypes.logistics.programmable-splitter")
require("prototypes.logistics.jump-pads")
require("prototypes.logistics.hyper-tubes")
require("prototypes.logistics.pipe")
require("prototypes.logistics.pipe-to-ground")
require("prototypes.logistics.pump")
require("prototypes.logistics.foundation")
require("prototypes.logistics.wall")

-- duplicate the "Anything", "Each" and "Everything" signals for "Any", "Any Undefined" and "Overflow" respectively
data:extend({
	{
		type = "virtual-signal",
		name = "signal-any",
		icon = "__base__/graphics/icons/signal/signal_anything.png",
		icon_mipmaps = 4,
		icon_size = 64,
		order = "s[splitter]-a[any]"
	},
	{
		type = "virtual-signal",
		name = "signal-any-undefined",
		icon = "__base__/graphics/icons/signal/signal_each.png",
		icon_mipmaps = 4,
		icon_size = 64,
		order = "s[splitter]-b[any-undefined]"
	},
	{
		type = "virtual-signal",
		name = "signal-overflow",
		icon = "__base__/graphics/icons/signal/signal_everything.png",
		icon_mipmaps = 4,
		icon_size = 64,
		order = "s[splitter]-c[overflow]"
	}
})
