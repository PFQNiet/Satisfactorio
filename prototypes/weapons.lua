require("prototypes.weapons.xeno-zapper")
require("prototypes.weapons.xeno-basher")
require("prototypes.weapons.rebar-gun")
require("prototypes.weapons.rifle")
require("prototypes.weapons.nobelisk")
require("prototypes.weapons.chainsaw")

data:extend{
	{type="item-subgroup",group="combat",name="melee",order="9"},
	{type="ammo-category",name="infinite"},
	{type="ammo-category",name="rebar"},
	{type="ammo-category",name="rifle"}
}
