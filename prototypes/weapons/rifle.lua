-- modifiy submachine-gun
local name = "rifle"
local item = table.deepcopy(data.raw.gun["submachine-gun"])
item.name = name
item.flags = {}
item.attack_parameters.cooldown = 12 -- 5 per second
item.attack_parameters.range = 50
item.icon = graphics.."icons/"..name..".png"
item.icon_mipmaps = 0
item.stack_size = 1

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"steel-pipe",25},
		{"heavy-modular-frame",3},
		{"circuit-board",20},
		{"screw",250}
	},
	result = name,
	energy_required = 30/4,
	category = "equipment",
	enabled = false
}
data:extend{item, recipe}

local ammoname = "rifle-cartridge"
item = table.deepcopy(data.raw.ammo["firearm-magazine"])
item.name = ammoname
item.flags = {}
item.ammo_type.action[1].action_delivery[1].target_effects[2].damage.amount = 6
item.reload_time = 180
item.icon = graphics.."icons/"..ammoname..".png"
item.icon_mipmaps = 0
item.magazine_size = 15
item.stack_size = 50
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"smokeless-powder",2},
		{"copper-sheet",3}
	},
	result = ammoname,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 5, true)
data:extend{item, recipe}
