-- dummy entities that do nothing but produce pollution, which will take on the role of radiation in this mod
-- control will monitor chunks and spawn these entities to produce the appropriate amount of pollution
local empty = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}
local base = {
	type = "simple-entity",
	name = "radioactivity-0",
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selectable_in_game = false,
	flags = {"hidden"},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/uranium-ore.png",
	icon_size = 64,
	picture = empty,
	emissions_per_second = 1/60
}
data:extend({base})

for i=1,31 do
	local copy = table.deepcopy(base)
	copy.name = "radioactivity-"..i
	copy.emissions_per_second = bit32.lshift(1,i)/60
	data:extend({copy})
end

data:extend({
	{
		type = "damage-type",
		name = "radiation"
	}
})
data.raw['gui-style'].default['radioactivity-progressbar'] = {
	color = {1,0,0},
	bar_width = 13,
	horizontally_stretchable = "on",
	type = "progressbar_style"
}
