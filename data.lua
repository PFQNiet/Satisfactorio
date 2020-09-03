data:extend({
	{type="fuel-category",name="carbon"},
	{type="recipe-category",name="building"},
	{type="recipe-category",name="unbuilding"},
	{type="recipe-category",name="equipment"},
	{type="recipe-category",name="constructing"},
	{type="recipe-category",name="assembling"},
	{type="recipe-category",name="manufacturing"},
	{type="recipe-category",name="refining"},
	{type="recipe-category",name="hub-progressing"},
	{type="item-group",name="special",order="a",icon="__base__/graphics/item-group/effects.png",icon_size=64},
	{type="item-subgroup",group="special",name="special",order="s-a-a"},
	{type="item-subgroup",group="special",name="special-undo",order="s-b-a"},
	{type="item-subgroup",group="logistics",name="belt-undo",order="s-a-a"},
	{type="item-subgroup",group="production",name="production-fluid",order="s-a-a"},
	{type="item-subgroup",group="production",name="production-manufacturer",order="s-a-b"},
	{type="item-subgroup",group="production",name="production-miner",order="s-a-c"},
	{type="item-subgroup",group="production",name="production-smelter",order="s-a-d"},
	{type="item-subgroup",group="production",name="production-workstation",order="s-a-e"},
	{type="item-subgroup",group="production",name="production-fluid-undo",order="s-b-a"},
	{type="item-subgroup",group="production",name="production-manufacturer-undo",order="s-b-b"},
	{type="item-subgroup",group="production",name="production-miner-undo",order="s-b-c"},
	{type="item-subgroup",group="production",name="production-smelter-undo",order="s-b-d"},
	{type="item-subgroup",group="production",name="production-workstation-undo",order="s-b-e"}
})
data.raw.character.character.crafting_categories = {"building","unbuilding"}
table.insert(data.raw['god-controller'].default.crafting_categories, "building")
table.insert(data.raw['god-controller'].default.crafting_categories, "unbuilding")

require("prototypes.resources")
require("prototypes.materials")
require("prototypes.special")
require("prototypes.logistics")
require("prototypes.miners")
require("prototypes.constructors")
