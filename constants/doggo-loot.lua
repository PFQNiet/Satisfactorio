local loot = {
	["iron-ore"] = {
		probability = 11,
		amount_min = 23,
		amount_max = 33
	},
	["copper-ore"] = {
		probability = 11,
		amount_min = 25,
		amount_max = 45
	},
	["stone"] = {
		probability = 10,
		amount_min = 10,
		amount_max = 30
	},
	["flower-petals"] = {
		probability = 9,
		amount_min = 20,
		amount_max = 24
	},
	["paleberry"] = {
		probability = 6,
		amount_min = 2,
		amount_max = 2
	},
	["raw-quartz"] = {
		probability = 5.5,
		amount_min = 5,
		amount_max = 7
	},
	["wood"] = {
		probability = 5.5,
		amount_min = 4,
		amount_max = 6
	},
	["caterium-ore"] = {
		probability = 5,
		amount_min = 5,
		amount_max = 6
	},
	["sulfur"] = {
		probability = 5,
		amount_min = 5,
		amount_max = 6
	},
	["mycelia"] = {
		probability = 5,
		amount_min = 10,
		amount_max = 11
	},
	["bacon-agaric"] = {
		probability = 4.5,
		amount_min = 1,
		amount_max = 1
	},
	["leaves"] = {
		probability = 4,
		amount_min = 20,
		amount_max = 24
	},
	["beryl-nut"] = {
		probability = 3.5,
		amount_min = 5,
		amount_max = 5
	},
	["coal"] = {
		probability = 3,
		amount_min = 14,
		amount_max = 15
	},
	["alien-carapace"] = {
		probability = 2.5,
		amount_min = 1,
		amount_max = 1
	},
	["alien-organs"] = {
		probability = 2.5,
		amount_min = 1,
		amount_max = 1
	},
	["nuclear-waste"] = {
		probability = 2.5,
		amount_min = 1,
		amount_max = 1
	},
	["green-power-slug"] = {
		probability = 1.5,
		amount_min = 1,
		amount_max = 1
	},
	["yellow-power-slug"] = {
		probability = 1.5,
		amount_min = 1,
		amount_max = 1
	},
	["purple-power-slug"] = {
		probability = 1.5,
		amount_min = 1,
		amount_max = 1
	}
}

local total = 0
for _,i in pairs(loot) do
	total = total + i.probability
end
assert(total == 100, "Lizard Doggo loot table totalled "..total.."/100")

return loot
