local name = "compacted-coal"
local item = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	subgroup = "mineral-resource",
	order = "e[coal]-b["..name.."]",
	stack_size = 100,
	fuel_category = "carbon",
	fuel_value = "630MJ"
}
-- exclusively via alt recipe
data:extend{item}
