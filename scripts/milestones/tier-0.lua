return {
	["hub-upgrade-1"] = {
		{type="unlock-recipe",recipe="equipment-workshop"},
		{type="unlock-recipe",recipe="equipment-workshop-undo"},
		{type="unlock-recipe",recipe="portable-miner"},
		{type="character-inventory-slots-bonus",modifier=3},
		{type="function",call=function(force)
			-- get HUB if it exists...
			if not global['hub-terminal'] or not global['hub-terminal'][force.name] then return end
			local hub = global['hub-terminal'][force.name]
			local terminal = game.get_surface(hub[1]).find_entity('the-hub-terminal',hub[2])
			if not terminal or not terminal.valid then return end
			-- add a personal storage chest (wooden-chest) to it
			require("scripts.lualib.the-hub").buildStorageChest()
		end}
	}
}

--[[
hub-tier0-hub-upgrade-1=[font=default-semibold][color=#ffe6c0]Unlocks Buildings:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=equipment-workshop] [color=#2cd23f]__ITEM__equipment-workshop__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Equipment:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=portable-miner] [color=#2cd23f]__ITEM__portable-miner__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Upgrades:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font]+3 Inventory slots
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=wooden-chest] [color=#2cd23f]__ITEM__wooden-chest__[/color] added to [item=the-hub] [color=#2cd23f]__ITEM__the-hub__[/color]

hub-tier0-hub-upgrade-2=[font=default-semibold][color=#ffe6c0]Unlocks Buildings:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=smelter] [color=#2cd23f]__ITEM__smelter__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Recipes:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=copper-ingot] [color=#2cd23f]__ITEM__copper-ingot__[/color]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=wire] [color=#2cd23f]__ITEM__wire__[/color]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=copper-cable] [color=#2cd23f]__ITEM__copper-cable__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Scanner:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=copper-ore] [color=#2cd23f]__ITEM__copper-ore__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Upgrades:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=biomass-burner] [color=#2cd23f]__ITEM__biomass-burner__[/color] added to [item=the-hub] [color=#2cd23f]__ITEM__the-hub__[/color]

hub-tier0-hub-upgrade-3=[font=default-semibold][color=#ffe6c0]Unlocks Buildings:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=constructor] [color=#2cd23f]__ITEM__constructor__[/color]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=small-electric-pole] [color=#2cd23f]__ITEM__small-electric-pole__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Recipes:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=concrete] [color=#2cd23f]__ITEM__concrete__[/color]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=screw] [color=#2cd23f]__ITEM__screw__[/color]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=reinforced-iron-plate] [color=#2cd23f]__ITEM__reinforced-iron-plate__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Scanner:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=stone] [color=#2cd23f]__ITEM__stone__[/color]

hub-tier0-hub-upgrade-4=[font=default-semibold][color=#ffe6c0]Unlocks Buildings:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=transport-belt] [color=#2cd23f]__ITEM__transport-belt__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Upgrades:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font]+3 Inventory slots

hub-tier0-hub-upgrade-5=[font=default-semibold][color=#ffe6c0]Unlocks Buildings:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=miner-mk-1] [color=#2cd23f]__ITEM__miner-mk-1__[/color]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=iron-chest] [color=#2cd23f]__ITEM__iron-chest__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Upgrades:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=biomass-burner] [color=#2cd23f]__ITEM__biomass-burner__[/color] added to [item=the-hub] [color=#2cd23f]__ITEM__the-hub__[/color]

hub-tier0-hub-upgrade-6=[font=default-semibold][color=#ffe6c0]Unlocks Buildings:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=space-elevator] [color=#2cd23f]__ITEM__space-elevator__[/color]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=biomass-burner] [color=#2cd23f]__ITEM__biomass-burner__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Recipes:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=biomass] [color=#2cd23f]__ITEM__biomass__[/color]
[font=default-semibold][color=#ffe6c0]Unlocks Upgrades:[/color][/font]
[font=default-semibold][color=#ffe6c0]   •  [/color][/font][item=ficsit-frighter] [color=#2cd23f]__ITEM__ficsit-freighter__[/color] added to [item=the-hub] [color=#2cd23f]__ITEM__the-hub__[/color]

]]
