-- modifiy submachine-gun
local name = "rifle"
local basename = "submachine-gun"
local item = data.raw.gun[basename]
item.attack_parameters.cooldown = 12 -- 5 per second
item.attack_parameters.range = 50
item.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
item.icon_mipmaps = 0
item.stack_size = 1
data.raw.recipe[basename] = {
	name = basename,
	type = "recipe",
	ingredients = {
		{"steel-pipe",25},
		{"heavy-modular-frame",3},
		{"electronic-circuit",20},
		{"screw",250}
	},
	result = basename,
	energy_required = 30/4,
	category = "equipment",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}

-- modify firearm-magazine
name = "rifle-cartridge"
basename = "firearm-magazine"
item = data.raw.ammo[basename]
item.ammo_type.action[1].action_delivery[1].target_effects[2].damage.amount = 6
item.reload_time = 180
item.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
item.icon_mipmaps = 0
item.magazine_size = 10
item.stack_size = 10 -- each "clip" holds 10 bullets so a stack is really 100 bullets, as it should be
data.raw.recipe[basename] = {
	name = basename,
	type = "recipe",
	ingredients = {
		{"map-marker",2},
		{"steel-pipe",20},
		{"black-powder",20},
		{"rubber",20}
	},
	result = basename, -- in Satisfactory the recipe is 1/10/10/10 for 5, so double it to make a single "clip"
	energy_required = 40,
	category = "manufacturing",
	enabled = false
}
data:extend({{
	name = basename.."-manual",
	type = "recipe",
	ingredients = {
		{"map-marker",2},
		{"steel-pipe",20},
		{"black-powder",20},
		{"rubber",20}
	},
	result = basename,
	energy_required = 10/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}})
