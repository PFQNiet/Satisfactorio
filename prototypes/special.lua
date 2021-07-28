require("prototypes.special.drop-pod")
require("prototypes.special.the-hub")
require("prototypes.special.mam")
require("prototypes.special.space-elevator")
require("prototypes.special.awesome-sink")
require("prototypes.special.awesome-shop")
require("prototypes.special.crash-sites")

data:extend{
	{type="item-group",name="special",order="91",icon=graphics.."item-group/special.png",icon_size=64},
	{type="item-subgroup",group="special",name="special",order="s-a"},

	{type="recipe-category",name="hub-progressing"},
	{type="recipe-category",name="space-elevator"},
	{type="recipe-category",name="mam"},
	{type="recipe-category",name="awesome-sink"},
	{type="recipe-category",name="awesome-shop"},

	{type="item-group",name="milestones",order="92",icon=graphics.."icons/the-hub.png",icon_size=64},
	{type="item-subgroup",group="milestones",name="hub-tier0",order="a"},
	{type="item-subgroup",group="milestones",name="hub-tier1",order="b"},
	{type="item-subgroup",group="milestones",name="hub-tier2",order="c"},
	{type="item-subgroup",group="milestones",name="hub-tier3",order="d"},
	{type="item-subgroup",group="milestones",name="hub-tier4",order="e"},
	{type="item-subgroup",group="milestones",name="hub-tier5",order="f"},
	{type="item-subgroup",group="milestones",name="hub-tier6",order="g"},
	{type="item-subgroup",group="milestones",name="hub-tier7",order="h"},
	{type="item-subgroup",group="milestones",name="hub-tier8",order="i"},

	{type="item-group",name="space-elevator-phases",order="x3",icon=graphics.."icons/space-elevator.png",icon_size=64},
	{type="item-subgroup",group="space-elevator-phases",name="space-elevator-phases",order="a"},
	{type="item-group",name="space-elevator",order="x3",icon=graphics.."icons/space-elevator.png",icon_size=64},
	{type="item-subgroup",group="space-elevator",name="space-parts-1",order="a"},
	{type="item-subgroup",group="space-elevator",name="space-parts-2",order="b"},
	{type="item-subgroup",group="space-elevator",name="space-parts-3",order="c"},
	{type="item-subgroup",group="space-elevator",name="space-parts-4",order="d"},

	{type="item-group",name="mam-research",order="x4",icon=graphics.."icons/mam.png",icon_size=64},
	{type="item-subgroup",group="mam-research",name="mam-hard-drive",order="a"},
	{type="item-subgroup",group="mam-research",name="mam-alien-organisms",order="b"},
	{type="item-subgroup",group="mam-research",name="mam-caterium",order="c"},
	{type="item-subgroup",group="mam-research",name="mam-flower-petals",order="d"},
	{type="item-subgroup",group="mam-research",name="mam-mycelia",order="e"},
	{type="item-subgroup",group="mam-research",name="mam-nutrients",order="f"},
	{type="item-subgroup",group="mam-research",name="mam-power-slugs",order="g"},
	{type="item-subgroup",group="mam-research",name="mam-quartz",order="h"},
	{type="item-subgroup",group="mam-research",name="mam-sulfur",order="i"}
}
