require("prototypes.vanilla-cleanup.disable-vanilla-recipes")
require("prototypes.vanilla-cleanup.hide-vanilla-techs")

-- remove fishing
data.raw.fish.fish.minable = nil
data.raw.capsule['raw-fish'].flags = {"hidden"}