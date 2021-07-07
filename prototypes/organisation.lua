require("prototypes.organisation.personal-storage-box")
require("prototypes.organisation.storage-container")
require("prototypes.organisation.industrial-storage-container")
require("prototypes.organisation.fluid-buffer")
require("prototypes.organisation.industrial-fluid-buffer")
require("prototypes.organisation.factory-light")
require("prototypes.organisation.lookout-tower")
require("prototypes.organisation.radar-tower")
require("prototypes.organisation.map-marker")
require("prototypes.organisation.object-scanner")

data:extend{
	{type="recipe-category",name="object-scanner"},
	-- fast-transfer hooks for containers
	{
		type = "custom-input",
		name = "fast-entity-transfer-hook",
		key_sequence = "",
		linked_game_control = "fast-entity-transfer",
	},
	{
		type = "custom-input",
		name = "fast-entity-split-hook",
		key_sequence = "",
		linked_game_control = "fast-entity-split",
	}
}
