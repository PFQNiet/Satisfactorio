-- modifiy submachine-gun
local name = "rifle"
local item = table.deepcopy(data.raw.gun["submachine-gun"])
item.name = name
item.flags = {}
item.attack_parameters.cooldown = 12 -- 5 per second
item.attack_parameters.range = 50
item.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
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
item.icon = "__Satisfactorio__/graphics/icons/"..ammoname..".png"
item.icon_mipmaps = 0
item.magazine_size = 10
item.stack_size = 10 -- each "clip" holds 10 bullets so a stack is really 100 bullets, as it should be
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"map-marker",2},
		{"steel-pipe",20},
		{"black-powder",20},
		{"rubber",20}
	},
	result = ammoname,
	-- in Satisfactory the recipe is 1/10/10/10 for 5, so double it to make a single "clip"
	energy_required = 40,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 10, true)
data:extend{item, recipe}
