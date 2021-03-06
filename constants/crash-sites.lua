---@class CrashSiteLootEntry
---@field probability number
---@field amount uint8[]

---@type table<string, CrashSiteLootEntry>
local loot = {
	["screw"] = {
		probability = 0.8,
		amount = {40,80}
	},
	["wire"] = {
		probability = 0.8,
		amount = {40,80}
	},
	["copper-cable"] = {
		probability = 0.6,
		amount = {30,60}
	},
	["reinforced-iron-plate"] = {
		probability = 0.5,
		amount = {15,30}
	},
	["modular-frame"] = {
		probability = 0.5,
		amount = {10,20}
	},
	["encased-industrial-beam"] = {
		probability = 0.5,
		amount = {25,50}
	},
	["heavy-modular-frame"] = {
		probability = 0.3,
		amount = {10,20}
	},
	["motor"] = {
		probability = 0.3,
		amount = {15,30}
	},
	["circuit-board"] = {
		probability = 0.3,
		amount = {25,50}
	},
	["computer"] = {
		probability = 0.2,
		amount = {10,20}
	},
	["ai-limiter"] = {
		probability = 0.15,
		amount = {8,16}
	},
	["high-speed-connector"] = {
		probability = 0.1,
		amount = {8,16}
	},
	["supercomputer"] = {
		probability = 0.05,
		amount = {4,8}
	},
	["heat-sink"] = {
		probability = 0.1,
		amount = {8,16}
	},
	["radio-control-unit"] = {
		probability = 0.02,
		amount = {2,4}
	},
	["battery"] = {
		probability = 0.1,
		amount = {5,10}
	},
	["uranium-waste"] = {
		probability = 0.01,
		amount = {50,100}
	}
}

---@class CrashSiteRequirementsProbabilities
---@field total number
---@field items table<string, number>
local reqs = {
	total = 100, -- chance of no item being needed, only power
	items = {
		["motor"] = 80,
		["rotor"] = 60,
		["screw"] = 50,
		["encased-industrial-beam"] = 40,
		["stator"] = 40,
		["steel-pipe"] = 30,
		["steel-beam"] = 30,
		["quickwire"] = 20,
		["modular-frame"] = 20,
		["crystal-oscillator"] = 20,
		["circuit-board"] = 20,
		["heavy-modular-frame"] = 20,
		["turbo-motor"] = 15,
		["ai-limiter"] = 15,
		["rubber"] = 15,
		["high-speed-connector"] = 15,
		["heat-sink"] = 15,
		["computer"] = 15,
		["black-powder"] = 10,
		["supercomputer"] = 10,
		["solid-biofuel"] = 10,
		["radio-control-unit"] = 10,
		["quartz-crystal"] = 10
	}
}
for _,v in pairs(reqs.items) do reqs.total = reqs.total + v end

return {
	loot = loot,
	requirements = reqs
}
