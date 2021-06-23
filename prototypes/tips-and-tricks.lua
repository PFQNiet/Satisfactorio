tiptrickutils = [[
	-- require("math2d")
	math2d = {position={
		ensure_xy = function(pos)
			local new_pos
			if pos.x ~= nil then
				new_pos = {x = pos.x, y = pos.y}
			else
				new_pos = {x = pos[1], y = pos[2]}
			end
			return new_pos
		end,
		rotate_vector = function(vector, angle_in_deg)
			local cosAngle = math.cos(math.rad(angle_in_deg))
			local sinAngle = math.sin(math.rad(angle_in_deg))
			vector = math2d.position.ensure_xy(vector)
			local x = cosAngle * vector.x - sinAngle * vector.y
			local y = sinAngle * vector.x + cosAngle * vector.y
			return {x = x, y = y}
		end,
		add = function(p1, p2)
			p1 = math2d.position.ensure_xy(p1)
			p2 = math2d.position.ensure_xy(p2)
			return {x = p1.x + p2.x, y = p1.y + p2.y}
		end
	}}

	-- input-output doesn't need any particular tracking here
	io = {
		addInput = function(entity, offset, target, direction)
			offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
			local position = math2d.position.add(entity.position, offset)
			direction = direction or defines.direction.north
			local exists = entity.surface.find_entity("loader-conveyor", position)
			if exists then return end

			local belt = entity.surface.create_entity{
				name = "loader-conveyor",
				position = position,
				direction = (entity.direction + direction) % 8,
				force = entity.force
			}
			local inserter_left = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction + direction) % 8,
				force = entity.force
			}
			inserter_left.pickup_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,0.25},((entity.direction+direction)%8)/8*360))
			inserter_left.drop_position = (target or entity).position
			inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local inserter_right = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction + direction) % 8,
				force = entity.force
			}
			inserter_right.pickup_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,0.25},((entity.direction+direction)%8)/8*360))
			inserter_right.drop_position = (target or entity).position
			inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local visual = rendering.draw_sprite{
				sprite = "utility.indication_line",
				orientation = ((entity.direction + direction) % 8)/8,
				render_layer = "arrow",
				target = entity,
				target_offset = {offset.x, offset.y},
				surface = entity.surface,
				only_in_alt_mode = true
			}
			return belt, inserter_left, inserter_right, visual
		end,
		addOutput = function(entity, offset, target, direction)
			offset = math2d.position.rotate_vector(offset, entity.direction/8*360)
			local position = math2d.position.add(entity.position, offset)
			direction = direction or defines.direction.north
			local exists = entity.surface.find_entity("loader-conveyor", position)
			if exists then return end

			local belt = entity.surface.create_entity{
				name = "loader-conveyor",
				position = position,
				direction = (entity.direction+direction)%8,
				force = entity.force
			}
			local inserter_left = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction+direction)%8,
				force = entity.force
			}
			inserter_left.pickup_position = (target or entity).position
			inserter_left.drop_position = math2d.position.add(position, math2d.position.rotate_vector({-0.25,-0.49},((entity.direction+direction)%8)/8*360))
			inserter_left.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local inserter_right = entity.surface.create_entity{
				name = "loader-inserter",
				position = entity.position,
				direction = (entity.direction+direction)%8,
				force = entity.force
			}
			inserter_right.pickup_position = (target or entity).position
			inserter_right.drop_position = math2d.position.add(position, math2d.position.rotate_vector({0.25,-0.49},((entity.direction+direction)%8)/8*360))
			inserter_right.inserter_filter_mode = "blacklist" -- allow all items by default, specific uses may override this
			local visual = rendering.draw_sprite{
				sprite = "utility.indication_arrow",
				orientation = ((entity.direction+direction)%8)/8,
				render_layer = "arrow",
				target = entity,
				target_offset = {offset.x, offset.y},
				surface = entity.surface,
				only_in_alt_mode = true
			}
			return belt, inserter_left, inserter_right, visual
		end,
		entities = {
			['smelter'] = {
				inputs = {{0,2}},
				outputs = {{0,-2}}
			},
			['constructor'] = {
				inputs = {{0,2}},
				outputs = {{0,-2}}
			},
			['assembler'] = {
				inputs = {{-1,3},{1,3}},
				outputs = {{0,-3}}
			},
			['miner-mk-1'] = {
				inputs = {},
				outputs = {{0,-6}}
			},
			['storage-container-placeholder'] = {
				inputs = {{0,2}},
				outputs = {{0,-2}}
			},
			['coal-generator-boiler'] = {
				inputs = {{1,1.5}},
				outputs = {}
			},
			['conveyor-splitter'] = {
				inputs = {{0,1}},
				outputs = {{0,-1},{-1,0,defines.direction.west},{1,0,defines.direction.west}}
			}
		},
		generate = function(surface)
			for key,data in pairs(io.entities) do
				local entities = surface.find_entities_filtered{name=key}
				for _,entity in pairs(entities) do
					for _,vector in pairs(data.inputs) do
						io.addInput(entity,{vector[1],vector[2]},entity,vector[3] or defines.direction.north)
					end
					for _,vector in pairs(data.outputs) do
						io.addOutput(entity,{vector[1],vector[2]},entity,vector[3] or defines.direction.north)
					end
				end
			end
		end
	}

]]

require("prototypes.tips-and-tricks.introduction")
require("prototypes.tips-and-tricks.show-info")
require("prototypes.tips-and-tricks.pipette")
data.raw['tips-and-tricks-item']['stack-transfers'].tutorial = nil
require("prototypes.tips-and-tricks.entity-transfers")
require("prototypes.tips-and-tricks.z-dropping")
require("prototypes.tips-and-tricks.shoot-targeting")
-- delete "Inserters" category
data.raw['tips-and-tricks-item-category']['inserters'] = nil
data.raw['tips-and-tricks-item']['inserters'] = nil
data.raw['tips-and-tricks-item']['burner-inserter-refueling'] = nil
data.raw['tips-and-tricks-item']['long-handed-inserters'] = nil
data.raw['tips-and-tricks-item']['move-between-labs'] = nil
data.raw['tips-and-tricks-item']['insertion-limits'] = nil
data.raw['tips-and-tricks-item']['limit-chests'] = nil
-- "Transport belt" tips don't really apply here
data.raw['tips-and-tricks-item-category']['belts'] = nil
data.raw['tips-and-tricks-item']['transport-belts'] = nil
data.raw['tips-and-tricks-item']['belt-lanes'] = nil
data.raw['tips-and-tricks-item']['splitters'] = nil
data.raw['tips-and-tricks-item']['splitter-filters'] = nil
data.raw['tips-and-tricks-item']['underground-belts'] = nil
-- "steam power" isn't used
data.raw['tips-and-tricks-item']['electric-network'] = nil
data.raw['tips-and-tricks-item']['electric-pole-connections'] = nil
data.raw['tips-and-tricks-item']['steam-power'] = nil
data.raw['tips-and-tricks-item']['connect-switch'] = nil
data.raw['tips-and-tricks-item']['low-power'].dependencies = nil
data.raw['tips-and-tricks-item']['low-power'].simulation = nil
data.raw['tips-and-tricks-item']['low-power'].image = "__Satisfactorio__/graphics/tips-and-tricks/power-trip.png"
require("prototypes.tips-and-tricks.copy-entity-settings")
data.raw['tips-and-tricks-item']['copy-paste-filters'] = nil -- Possibly repurpose this with Smart Splitters?
data.raw['tips-and-tricks-item']['copy-paste-requester-chest'] = nil
data.raw['tips-and-tricks-item']['copy-paste-spidertron'] = nil
require("prototypes.tips-and-tricks.drag-building")
-- remove "train" section, I can't be bothered making it work with electric trains XD
data.raw['tips-and-tricks-item-category']['trains'] = nil
data.raw['tips-and-tricks-item']['trains'] = nil
data.raw['tips-and-tricks-item']['rail-building'] = nil
data.raw['tips-and-tricks-item']['train-stops'] = nil
data.raw['tips-and-tricks-item']['rail-signals-basic'] = nil
data.raw['tips-and-tricks-item']['rail-signals-advanced'] = nil
data.raw['tips-and-tricks-item']['gate-over-rail'] = nil
data.raw['tips-and-tricks-item']['pump-connection'] = nil
data.raw['tips-and-tricks-item']['train-stop-same-name'] = nil
data.raw['tips-and-tricks-item']['ghost-rail-planner'] = nil
-- Drop the robot-related stuff
data.raw['tips-and-tricks-item-category']['logistic-network'] = nil
data.raw['tips-and-tricks-item']['logistic-network'] = nil
data.raw['tips-and-tricks-item']['personal-logistics'] = nil
data.raw['tips-and-tricks-item']['construction-robots'] = nil
data.raw['tips-and-tricks-item']['passive-provider-chest'] = nil
data.raw['tips-and-tricks-item']['storage-chest'] = nil
data.raw['tips-and-tricks-item']['requester-chest'] = nil
data.raw['tips-and-tricks-item']['active-provider-chest'] = nil
data.raw['tips-and-tricks-item']['buffer-chest'] = nil
-- No fast-replace (it only affects Miners and Belts anyway...)
data.raw['tips-and-tricks-item-category']['fast-replace'] = nil
data.raw['tips-and-tricks-item']['fast-replace'] = nil
data.raw['tips-and-tricks-item']['fast-replace-direction'] = nil
data.raw['tips-and-tricks-item']['fast-replace-belt-splitter'] = nil
data.raw['tips-and-tricks-item']['fast-replace-belt-underground'] = nil
require("prototypes.tips-and-tricks.ghost-building")
data.raw['tips-and-tricks-item']['rotating-assemblers'] = nil
data.raw['tips-and-tricks-item']['circuit-network'] = nil
