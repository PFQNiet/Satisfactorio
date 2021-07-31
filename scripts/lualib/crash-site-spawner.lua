-- modified copy of __core__.lualib.crash-site
-- main changes: wreckage is now on neutral force and calls raise_built
-- does not produce explosions or flames, as these sites are assumed to be old
-- also, the function returns the ship
local main_ship_name = "crash-site-spaceship"
local ship_parts = {
	{
		name = "crash-site-spaceship-wreck-big",
		variations = 2,
		angle_deviation = 0.1,
		max_distance = 25,
		min_separation = 2
	},
	{
		name = "crash-site-spaceship-wreck-medium",
		variations = 3,
		angle_deviation = 0.05,
		max_distance = 30,
		min_separation = 1
	},
	{
		name = "crash-site-spaceship-wreck-small",
		variations = 6,
		angle_deviation = 0.05,
		min_separation = 1
	}
}

local rotate = function(offset, angle)
	local x = offset[1]
	local y = offset[2]
	local rotated_x = x * math.cos(angle) - y * math.sin(angle)
	local rotated_y = x * math.sin(angle) + y * math.cos(angle)
	return {rotated_x, rotated_y}
end

local entry_angle = 0.70
local random = math.random
local get_offset = function(part)
	local angle = entry_angle + ((random() - 0.5) * part.angle_deviation)
	angle = angle - 0.25
	angle = angle * math.pi * 2
	local distance = 8 + (random() * (part.max_distance or 40))
	local offset = rotate({distance, 0}, angle)
	return offset
end

local get_name = function(part, k)
	if not part.variations then return part.name end
	local variant = k or random(part.variations)
	return part.name.."-"..variant
end

local get_lifetime = function(offset)
	--Generally, close to the ship, last longer.
	local distance = ((offset[1] * offset[1]) + (offset[2] * offset[2])) ^ 0.5
	local time = random(60 * 20, 60 * 30) - math.min(distance * 100, 15 * 60)
	return time
end

local get_random_position = function(box, x_scale, y_scale)
	local xs = x_scale or 1
	local ys = y_scale or 1
	local x1 = box.left_top.x
	local y1 = box.left_top.y
	local x2 = box.right_bottom.x
	local y2 = box.right_bottom.y
	local x = ((x2 - x1) * xs * (random() - 0.5)) + ((x1 + x2) / 2)
	local y = ((y2 - y1) * ys * (random() - 0.5)) + ((y1 + y2) / 2)
	return {x, y}
end

local random_from_map = function(map)
	local array = {}
	local i = 1
	for k in pairs (map) do
		array[i] = k
		i = i + 1
	end
	local key = array[random(#array)]
	local value = map[key]
	return key, value
end

local insert_items_randomly = function(entities, items)
	local item_prototypes = game.item_prototypes
	for name in pairs (items) do
		if not item_prototypes[name] then
			items[name] = nil
		end
	end
	if not next(items) then return end

	for unit_number, entity in pairs (entities) do
		if not entity.valid then
			entities[unit_number] = nil
		end
	end
	if not next(entities) then return end

	local bailout = 1000
	while true do
		local item_name, count = random_from_map(items)
		local _, entity = random_from_map(entities)
		local inserted = entity.insert{name = item_name, count = 1}
		if inserted == count then
			items[item_name] = nil
		else
			items[item_name] = count - inserted
		end

		if not next(items) then break end
		bailout = bailout - 1
		if bailout <= 0 then break end
	end
end

local lib = {}

---@param surface LuaSurface
---@param position Position
---@param loot table<string,uint8>
---@return LuaEntity Spaceship
lib.create_crash_site = function(surface, position, loot)
	local main_ship = surface.create_entity{
		name = main_ship_name,
		position = position,
		force = "neutral",
		create_build_effect_smoke = false,
		raise_built = true
	}

	local box = main_ship.bounding_box
	for _, entity in pairs(surface.find_entities_filtered{type = {"tree", "simple-entity"}, position = position, radius = 1 + main_ship.get_radius()}) do
		if entity.valid then
			if entity.type == "tree" then
				entity.die()
			else
				entity.destroy()
			end
		end
	end

	local wreck_parts = {}

	for _, part in pairs(ship_parts) do
		for k = 1, (part.variations or 1) do
			local name = get_name(part, k)
			for _ = 1, part.repeat_count or 1 do
				local part_position
				local count = 0
				local offset
				while true do
					offset = get_offset(part)
					local x = (position[1] or position.x) + offset[1]
					local y = (position[2] or position.y) + offset[2]
					part_position = {x, y}

					local can_place = surface.can_place_entity{
						name = name,
						position = part_position,
						force = "player",
						build_check_type = defines.build_check_type.manual_ghost,
						forced = true
					}

					if can_place then
						if not part.min_separation or surface.count_entities_filtered{position = part_position, radius = part.min_separation, limit = 1, type = "tree", invert = true} == 0 then
							break
						end
					end

					count = count + 1
					if count > 20 then
						part_position = surface.find_non_colliding_position(name, part_position, 50, 4)
						break
					end
				end

				if part_position then
					local entity = surface.create_entity{
						name = name,
						position = part_position,
						force = "neutral",
						create_build_effect_smoke = false,
						raise_built = true
					}

					if entity.get_output_inventory() and #entity.get_output_inventory() > 0 then
						wreck_parts[entity.unit_number] = entity
					end

					for _, other in pairs(surface.find_entities_filtered{type = {"tree", "simple-entity"}, position = part_position, radius = 1 + entity.get_radius()}) do
						if other.type == "tree" then
							other.die()
						else
							other.destroy()
						end
					end
				end
			end
		end
	end

	insert_items_randomly(wreck_parts, loot)
	return main_ship
end

return lib
