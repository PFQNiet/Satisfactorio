return {
	type = "tips-and-tricks-item",
	name = "melee-combat",
	order = "b[melee-combat]",
	tag = "[item=xeno-zapper]",
	trigger = {
		type = "time-elapsed",
		ticks = 30*60
	},
	simulation = {
		init = tipTrickSetup{
			player = {
				position = {-8,0.5},
				direction = defines.direction.east,
				use_cursor = true
			},
			setup = [[
				-- extend board slightly so biter isn't off-the-map
				game.surfaces[1].build_checkerboard{{10, -10}, {25, 10}}
				player.insert("xeno-zapper")
				graphics = {
					slot = rendering.draw_sprite{
						sprite = "utility/slot",
						target = {-14,7},
						surface = game.surfaces[1]
					},
					gun = rendering.draw_sprite{
						sprite = "item/xeno-zapper",
						target = {-14,7},
						x_scale = 1.5,
						y_scale = 1.5,
						surface = game.surfaces[1]
					},
					-- cooldown between zaps is 20 ticks, reload time is 60 ticks
					cooldown = {}
				}
				function generateCooldownGraphics()
					local stepsize = 2/15
					local scale = 76/2/32 -- size of the slot graphic, in tiles, halved
					local color = {0.75,0.75,0,0.75}
					local function addPolygon(points)
						for i,p in pairs(points) do
							points[i] = {target={
								p[1] * scale,
								p[2] * scale
							}}
						end
						table.insert(graphics.cooldown, rendering.draw_polygon{
							color = color,
							target = {-14,7},
							vertices = points,
							surface = game.surfaces[1],
							visible = false
						})
					end
					-- 15 to a side, starting from the middle of the top side
					-- means 7 then a corner, 14 right, corner, 14 bottom, corner, 14 left, corner, 7
					for i=0,6 do
						addPolygon{{i*stepsize,-1}, {(i+1)*stepsize,-1}, {0,0}}
					end
					addPolygon{{7*stepsize,-1}, {1,-7*stepsize}, {0,0}}
					for i=-7,6 do
						addPolygon{{1,i*stepsize}, {1,(i+1)*stepsize}, {0,0}}
					end
					addPolygon{{1,7*stepsize}, {7*stepsize,1}, {0,0}}
					for i=7,-6,-1 do
						addPolygon{{i*stepsize,1}, {(i-1)*stepsize,1}, {0,0}}
					end
					addPolygon{{-7*stepsize,1}, {-1,7*stepsize}, {0,0}}
					for i=7,-6,-1 do
						addPolygon{{-1,i*stepsize}, {-1,(i-1)*stepsize}, {0,0}}
					end
					addPolygon{{-1,-7*stepsize}, {-7*stepsize,-1}, {0,0}}
					for i=-7,-1 do
						addPolygon{{i*stepsize,-1}, {(i+1)*stepsize,-1}, {0,0}}
					end
					assert(#graphics.cooldown == 60, "Expected 60 polygons, got "..#graphics.cooldown)
				end
				generateCooldownGraphics()
				function setCooldown(fill)
					for i=1,60 do
						rendering.set_visible(graphics.cooldown[i], i<=fill*60)
					end
				end
			]],
			sequence = {
				{ -- create enemy
					setup = [[
						biter = game.surfaces[1].create_entity{
							name = "fluffy-tailed-hog",
							position = {20, -4},
							force = "enemy"
						}
						biter.set_command{
							type = defines.command.attack,
							target = player.character
						}
						local count = 60
					]],
					update = "count = count-1",
					proceed = "count <= 0"
				},
				{ -- run towards enemy
					setup = [[
						local ammoinventory = player.character.get_inventory(defines.inventory.character_ammo)
						ammoinventory.insert("xeno-zapper-ammo")
						local zapcooldown = 0
						local biterhealth = biter.health
					]],
					update = [[
						runTowards(biter)
						player.shooting_state = {state = defines.shooting.shooting_enemies, position = biter.position}
						game.move_cursor({position=biter.position})
						if biter.health ~= biterhealth then
							-- zapped 'em, set cooldown
							zapcooldown = 20
							biterhealth = biter.health
						end
						if zapcooldown > 0 then
							local fill = (21-zapcooldown) / 20
							zapcooldown = zapcooldown-1
							if zapcooldown == 0 then
								setCooldown(0)
							else
								setCooldown(fill)
							end
						end
					]],
					proceed = "ammoinventory.is_empty()"
				},
				{ -- back away while reloading
					setup = "local count = 80",
					update = [[
						runTowards{position={x=-6,y=4}}
						game.move_cursor({position=biter.position})
						if count >= 20 then
							local fill = (81-count) / 60
							if count == 20 then
								setCooldown(0)
							else
								setCooldown(fill)
							end
						end
						count = count - 1
					]],
					proceed = "count <= 0"
				},
				{ -- go for round 2
					setup = [[
						local ammoinventory = player.character.get_inventory(defines.inventory.character_ammo)
						ammoinventory.insert("xeno-zapper-ammo")
						local zapcooldown = 0
						local biterhealth = biter.health
					]],
					update = [[
						if biter.valid then
							runTowards(biter)
							player.shooting_state = {state = defines.shooting.shooting_enemies, position = biter.position}
							game.move_cursor({position=biter.position})
							if biter.health ~= biterhealth then
								-- zapped 'em, set cooldown
								zapcooldown = 20
								biterhealth = biter.health
							end
						end
						if zapcooldown > 0 then
							local fill = (21-zapcooldown) / 20
							zapcooldown = zapcooldown-1
							if zapcooldown == 0 then
								setCooldown(0)
							else
								setCooldown(fill)
							end
						end
					]],
					proceed = "not biter.valid"
				},
				{ -- mission accomplished, returning to base
					setup = [[
						-- ammo should be depleted, but just in case...
						player.character.get_inventory(defines.inventory.character_ammo).clear()
						local cooldown = 60
					]],
					update = [[
						local retreat = runTowards{position={x=-8,y=0.5}}
						game.move_cursor({position={-8,0.5}})
						if cooldown > 0 then
							local fill = (61-cooldown) / 60
							cooldown = cooldown - 1
							if cooldown == 0 then
								setCooldown(0)
							else
								setCooldown(fill)
							end
						end
					]],
					proceed = "retreat and cooldown == 0"
				}
			}
		}
	}
}