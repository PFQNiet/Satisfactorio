local max_belt_tier = 5
local function makeConveyorBelts(params)
	---@type int
	local tier = params.tier
	---@type int
	local speed = params.speed
	---@type string
	local material = params.material
	---@type string
	local image_dir = params.graphics.path
	---@type string
	local image_belt = params.graphics.belt
	---@type string
	local image_frame = params.graphics.frame

	local beltname = "conveyor-belt-mk-"..tier
	local undergroundname = "conveyor-lift-mk-"..tier

	local belt = table.deepcopy(data.raw["transport-belt"]["express-transport-belt"])
	belt.name = beltname
	belt.icon = graphics.."icons/"..beltname..".png"
	belt.icon_size = 64
	belt.icon_mipmaps = 0
	belt.max_health = 1
	belt.speed = speed/256
	belt.minable.result = beltname
	belt.related_underground_belt = undergroundname
	belt.next_upgrade = tier < max_belt_tier and "conveyor-belt-mk-"..(tier+1) or nil
	belt.belt_animation_set.animation_set.filename = image_dir.."/"..image_belt.."/"..image_belt..".png"
	belt.belt_animation_set.animation_set.hr_version.filename = image_dir.."/"..image_belt.."/hr-"..image_belt..".png"

	local beltitem = {
		type = "item",
		name = beltname,
		place_result = beltname,
		icon = belt.icon,
		icon_size = belt.icon_size,
		stack_size = 50,
		subgroup = "belt",
		order = "a[transport-belt]-"..tier.."["..beltname.."]"
	}

	local beltrecipe = makeBuildingRecipe{
		name = beltname,
		ingredients = {{material,1}},
		result = beltname
	}

	local underground = table.deepcopy(data.raw["underground-belt"]["express-underground-belt"])
	underground.name = undergroundname
	underground.icon = graphics.."icons/"..undergroundname..".png"
	underground.icon_size = 64
	underground.icon_mipmaps = 0
	underground.max_health = 1
	underground.speed = speed/256
	underground.minable.result = undergroundname
	underground.max_distance = 5
	underground.next_upgrade = tier < max_belt_tier and "conveyor-lift-mk-"..(tier+1) or nil
	underground.belt_animation_set.animation_set.filename = belt.belt_animation_set.animation_set.filename
	underground.belt_animation_set.animation_set.hr_version.filename = belt.belt_animation_set.animation_set.hr_version.filename
	underground.structure.direction_in.sheet.filename = image_dir.."/"..image_frame.."/"..image_frame.."-structure.png"
	underground.structure.direction_in.sheet.hr_version.filename = image_dir.."/"..image_frame.."/hr-"..image_frame.."-structure.png"
	underground.structure.direction_in_side_loading.sheet.filename = image_dir.."/"..image_frame.."/"..image_frame.."-structure.png"
	underground.structure.direction_in_side_loading.sheet.hr_version.filename = image_dir.."/"..image_frame.."/hr-"..image_frame.."-structure.png"
	underground.structure.direction_out.sheet.filename = image_dir.."/"..image_frame.."/"..image_frame.."-structure.png"
	underground.structure.direction_out.sheet.hr_version.filename = image_dir.."/"..image_frame.."/hr-"..image_frame.."-structure.png"
	underground.structure.direction_out_side_loading.sheet.filename = image_dir.."/"..image_frame.."/"..image_frame.."-structure.png"
	underground.structure.direction_out_side_loading.sheet.hr_version.filename = image_dir.."/"..image_frame.."/hr-"..image_frame.."-structure.png"
	underground.structure.back_patch.sheet.filename = image_dir.."/"..image_frame.."/"..image_frame.."-structure-back-patch.png"
	underground.structure.back_patch.sheet.hr_version.filename = image_dir.."/"..image_frame.."/hr-"..image_frame.."-structure-back-patch.png"
	underground.structure.front_patch.sheet.filename = image_dir.."/"..image_frame.."/"..image_frame.."-structure-front-patch.png"
	underground.structure.front_patch.sheet.hr_version.filename = image_dir.."/"..image_frame.."/hr-"..image_frame.."-structure-front-patch.png"

	local undergrounditem = {
		type = "item",
		name = undergroundname,
		place_result = undergroundname,
		icon = underground.icon,
		icon_size = underground.icon_size,
		stack_size = 50,
		subgroup = "belt",
		order = "b[underground-belt]-"..tier.."["..undergroundname.."]"
	}

	local undergroundrecipe = makeBuildingRecipe{
		name = undergroundname,
		ingredients = {{material,4}},
		result = undergroundname
	}

	data:extend{belt, beltitem, beltrecipe, underground, undergrounditem, undergroundrecipe}
end

makeConveyorBelts{
	tier = 1,
	speed = 1,
	material = "iron-plate",
	graphics = {
		path = graphics.."entities",
		belt = "transport-belt",
		frame = "underground-belt"
	}
}
makeConveyorBelts{
	tier = 2,
	speed = 2,
	material = "reinforced-iron-plate",
	graphics = {
		path = "__base__/graphics/entity",
		belt = "fast-transport-belt",
		frame = "fast-underground-belt"
	}
}
makeConveyorBelts{
	tier = 3,
	speed = 3,
	material = "steel-beam",
	graphics = {
		path = "__base__/graphics/entity",
		belt = "express-transport-belt",
		frame = "express-underground-belt"
	}
}
makeConveyorBelts{
	tier = 4,
	speed = 5,
	material = "encased-industrial-beam",
	graphics = {
		path = graphics.."entities",
		belt = "turbo-transport-belt",
		frame = "turbo-underground-belt"
	}
}
makeConveyorBelts{
	tier = 5,
	speed = 7,
	material = "alclad-aluminium-sheet",
	graphics = {
		path = graphics.."entities",
		belt = "ultimate-transport-belt",
		frame = "ultimate-underground-belt"
	}
}
