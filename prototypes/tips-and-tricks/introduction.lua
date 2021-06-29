return {
	type = "tips-and-tricks-item",
	name = "introduction",
	order = "a[introduction]",
	starting_status = "unlocked",
	simulation = {
		init = tipTrickSetup{
			use_io = true,
			setup = [[
				-- build a copper ore => cable setup in perfect ratio, with items on the belts!
				local surface = game.surfaces[1]
				local north = defines.direction.north
				local east = defines.direction.east
				local south = defines.direction.south
				local west = defines.direction.west
				local names = {
					belt = "conveyor-belt-mk-1",
					miner = "miner-mk-1",
					minerbox = "miner-box",
					splitter = "conveyor-splitter",
					merger = "conveyor-merger",
					splitterbox = "merger-splitter-box",
					smelter = "smelter",
					constructor = "constructor",
					infinity = "infinity-storage-container-placeholder",
					infinitybox = "infinity-storage-container",
					powerpole = "power-pole-mk-2",
					eei = "electric-energy-interface",
					ore = "copper-ore",
					ingot = "copper-ingot",
					wire = "wire",
					cable = "copper-cable"
				}
				-- createLoader(position, direction, tier, entity, mode)

				local function putItemsOnBelt(belt, item, halfway)
					local position = halfway and 0.5 or 0
					belt.get_transport_line(1).insert_at(position, {name=item})
					belt.get_transport_line(2).insert_at(position, {name=item})
				end

				-- miner
				surface.create_entity{name=names.ore, position={-25.5,0.5}, force="neutral", amount=120}
				surface.create_entity{name="miner-mk-1", position={-25.5,0.5}, direction=east, force="player"}
				local buffer = surface.create_entity{name="miner-box", position={-25.5,0.5}, force="player"}
				local loader = createLoader({-19.5,0.5}, east, 1, buffer, "output")
				local belt
				putItemsOnBelt(loader.belt, names.ore)
				putItemsOnBelt(loader.belt, names.ore, true)
				surface.create_entity{name=names.powerpole, position={-19.5,-3.5}, force="player"}
				surface.create_entity{name=names.eei, position={-22,-4}, force="player"}
				for x=-18.5,-15.5,1 do
					belt = surface.create_entity{name=names.belt, position={x,0.5}, direction=east, force="player"}
					putItemsOnBelt(belt, names.ore)
					putItemsOnBelt(belt, names.ore, true)
				end
				-- first splitter
				surface.create_entity{name=names.splitter, position={-13.5,0.5}, direction=east, force="player"}
				buffer = surface.create_entity{name=names.splitterbox, position={-13.5,0.5}, force="player"}
				createLoader({-14.5,0.5}, east, 1, buffer, "input")
				loader = createLoader({-13.5,-0.5}, north, 1, buffer, "output")
				putItemsOnBelt(loader.belt, names.ore)
				loader = createLoader({-13.5,1.5}, south, 1, buffer, "output")
				putItemsOnBelt(loader.belt, names.ore, true)
				createLoader({-12.5,0.5}, east, 0, buffer, "output")

				-- begin north branch
				for y=-1.5,-4.5,-1 do
					belt = surface.create_entity{name=names.belt, position={-13.5,y}, direction=north, force="player"}
					putItemsOnBelt(belt, names.ore)
				end
				belt = surface.create_entity{name=names.belt, position={-13.5,-5.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.ore)
				local smelter = surface.create_entity{name=names.smelter, position={-10.5,-5.5}, direction=east, force="player", recipe=names.ingot}
				createLoader({-12.5,-5.5}, east, 1, smelter, "input")
				smelter.insert{name=names.ore,count=4}
				surface.create_entity{name=names.powerpole, position={-10.5,-3.5}, force="player"}
				loader = createLoader({-8.5,-5.5}, east, 1, smelter, "output")
				putItemsOnBelt(loader.belt, names.ingot)
				belt = surface.create_entity{name=names.belt, position={-7.5,-5.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.ingot)
				-- north splitter
				surface.create_entity{name=names.splitter, position={-5.5,-5.5}, direction=east, force="player"}
				buffer = surface.create_entity{name=names.splitterbox, position={-5.5,-5.5}, force="player"}
				createLoader({-6.5,-5.5}, east, 1, buffer, "input")
				createLoader({-5.5,-6.5}, north, 0, buffer, "output")

				-- north topside
				loader = createLoader({-4.5,-5.5}, east, 1, buffer, "output")
				putItemsOnBelt(loader.belt, names.ingot)
				surface.create_entity{name=names.belt, position={-3.5,-5.5}, direction=east, force="player"}
				local constructor = surface.create_entity{name=names.constructor, position={-0.5,-5.5}, direction=east, force="player", recipe=names.wire}
				createLoader({-2.5,-5.5}, east, 1, constructor, "input")
				constructor.insert{name=names.ingot,count=4}
				surface.create_entity{name=names.powerpole, position={-1.5,-3.5}, force="player"}
				loader = createLoader({1.5,-5.5}, east, 1, constructor, "output")
				putItemsOnBelt(loader.belt, names.wire)
				for x=2.5,3.5,1 do
					belt = surface.create_entity{name=names.belt, position={x,-5.5}, direction=east, force="player"}
					putItemsOnBelt(belt, names.wire)
				end
				for y=-5.5,-3.5,1 do
					belt = surface.create_entity{name=names.belt, position={4.5,y}, direction=south, force="player"}
					putItemsOnBelt(belt, names.wire)
				end
				-- north bottomside, ingots on every 2nd belt
				loader = createLoader({-5.5,-4.5}, south, 1, buffer, "output")
				belt = surface.create_entity{name=names.belt, position={-5.5,-3.5}, direction=south, force="player"}
				putItemsOnBelt(belt, names.ingot)
				surface.create_entity{name=names.belt, position={-5.5,-2.5}, direction=south, force="player"}
				for x=-5.5,-3.5,1 do
					belt = surface.create_entity{name=names.belt, position={x,-1.5}, direction=east, force="player"}
					if x ~= -2.5 then putItemsOnBelt(belt, names.ingot) end
				end
				constructor = surface.create_entity{name=names.constructor, position={-0.5,-1.5}, direction=east, force="player", recipe=names.wire}
				constructor.insert{name=names.ingot,count=4}
				createLoader({-2.5,-1.5}, east, 1, constructor, "input")
				loader = createLoader({1.5,-1.5}, east, 1, constructor, "output")
				putItemsOnBelt(loader.belt, names.wire)
				belt = surface.create_entity{name=names.belt, position={2.5,-1.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.wire)

				-- north merger
				surface.create_entity{name=names.merger, position={4.5,-1.5}, direction=east, force="player"}
				buffer = surface.create_entity{name=names.splitterbox, position={4.5,-1.5}, force="player"}
				createLoader({4.5,-0.5}, north, 0, buffer, "input")
				createLoader({3.5,-1.5}, east, 1, buffer, "input")
				createLoader({4.5,-2.5}, south, 1, buffer, "input")
				loader = createLoader({5.5,-1.5}, east, 1, buffer, "output")
				putItemsOnBelt(loader.belt, names.wire)
				putItemsOnBelt(loader.belt, names.wire, true)
				belt = surface.create_entity{name=names.belt, position={6.5,-1.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.wire)
				putItemsOnBelt(belt, names.wire, true)

				-- north cables
				surface.create_entity{name=names.powerpole, position={7.5,-3.5}, force="player"}
				constructor = surface.create_entity{name=names.constructor, position={9.5,-1.5}, direction=east, force="player", recipe=names.cable}
				constructor.insert{name=names.wire,count=4}
				createLoader({7.5,-1.5}, east, 1, constructor, "input")
				loader = createLoader({11.5,-1.5}, east, 1, constructor, "output")
				putItemsOnBelt(loader.belt, names.cable)
				belt = surface.create_entity{name=names.belt, position={12.5,-1.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.cable)
				belt = surface.create_entity{name=names.belt, position={13.5,-1.5}, direction=south, force="player"}
				putItemsOnBelt(belt, names.cable)

				-- begin south branch
				for y=2.5,5.5,1 do
					belt = surface.create_entity{name=names.belt, position={-13.5,y}, direction=south, force="player"}
					putItemsOnBelt(belt, names.ore, true)
				end
				belt = surface.create_entity{name=names.belt, position={-13.5,6.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.ore)
				smelter = surface.create_entity{name=names.smelter, position={-10.5,6.5}, direction=east, force="player", recipe=names.ingot}
				createLoader({-12.5,6.5}, east, 1, smelter, "input")
				smelter.insert{name=names.ore,count=4}
				surface.create_entity{name=names.powerpole, position={-10.5,4.5}, force="player"}
				loader = createLoader({-8.5,6.5}, east, 1, smelter, "output")
				putItemsOnBelt(loader.belt, names.ingot)
				belt = surface.create_entity{name=names.belt, position={-7.5,6.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.ingot)
				-- south splitter
				surface.create_entity{name=names.splitter, position={-5.5,6.5}, direction=east, force="player"}
				buffer = surface.create_entity{name=names.splitterbox, position={-5.5,6.5}, force="player"}
				createLoader({-6.5,6.5}, east, 1, buffer, "input")
				createLoader({-5.5,7.5}, south, 0, buffer, "output")

				-- south bottomside
				loader = createLoader({-4.5,6.5}, east, 1, buffer, "output")
				putItemsOnBelt(loader.belt, names.ingot)
				surface.create_entity{name=names.belt, position={-3.5,6.5}, direction=east, force="player"}
				constructor = surface.create_entity{name=names.constructor, position={-0.5,6.5}, direction=east, force="player", recipe=names.wire}
				createLoader({-2.5,6.5}, east, 1, constructor, "input")
				constructor.insert{name=names.ingot,count=4}
				surface.create_entity{name=names.powerpole, position={-1.5,4.5}, force="player"}
				loader = createLoader({1.5,6.5}, east, 1, constructor, "output")
				putItemsOnBelt(loader.belt, names.wire)
				for x=2.5,3.5,1 do
					belt = surface.create_entity{name=names.belt, position={x,6.5}, direction=east, force="player"}
					putItemsOnBelt(belt, names.wire)
				end
				for y=6.5,4.5,-1 do
					belt = surface.create_entity{name=names.belt, position={4.5,y}, direction=north, force="player"}
					putItemsOnBelt(belt, names.wire)
				end
				-- south topside, ingots on every 2nd belt
				loader = createLoader({-5.5,5.5}, north, 1, buffer, "output")
				belt = surface.create_entity{name=names.belt, position={-5.5,4.5}, direction=north, force="player"}
				putItemsOnBelt(belt, names.ingot)
				surface.create_entity{name=names.belt, position={-5.5,3.5}, direction=north, force="player"}
				for x=-5.5,-3.5,1 do
					belt = surface.create_entity{name=names.belt, position={x,2.5}, direction=east, force="player"}
					if x ~= -2.5 then putItemsOnBelt(belt, names.ingot) end
				end
				constructor = surface.create_entity{name=names.constructor, position={-0.5,2.5}, direction=east, force="player", recipe=names.wire}
				constructor.insert{name=names.ingot,count=4}
				createLoader({-2.5,2.5}, east, 1, constructor, "input")
				loader = createLoader({1.5,2.5}, east, 1, constructor, "output")
				putItemsOnBelt(loader.belt, names.wire)
				belt = surface.create_entity{name=names.belt, position={2.5,2.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.wire)

				-- south merger
				surface.create_entity{name=names.merger, position={4.5,2.5}, direction=east, force="player"}
				buffer = surface.create_entity{name=names.splitterbox, position={4.5,2.5}, force="player"}
				createLoader({4.5,1.5}, south, 0, buffer, "input")
				createLoader({3.5,2.5}, east, 1, buffer, "input")
				createLoader({4.5,3.5}, north, 1, buffer, "input")
				loader = createLoader({5.5,2.5}, east, 1, buffer, "output")
				putItemsOnBelt(loader.belt, names.wire)
				putItemsOnBelt(loader.belt, names.wire, true)
				belt = surface.create_entity{name=names.belt, position={6.5,2.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.wire)
				putItemsOnBelt(belt, names.wire, true)

				-- south cables
				surface.create_entity{name=names.powerpole, position={7.5,4.5}, force="player"}
				constructor = surface.create_entity{name=names.constructor, position={9.5,2.5}, direction=east, force="player", recipe=names.cable}
				constructor.insert{name=names.wire,count=4}
				createLoader({7.5,2.5}, east, 1, constructor, "input")
				loader = createLoader({11.5,2.5}, east, 1, constructor, "output")
				putItemsOnBelt(loader.belt, names.cable)
				belt = surface.create_entity{name=names.belt, position={12.5,2.5}, direction=east, force="player"}
				putItemsOnBelt(belt, names.cable)
				belt = surface.create_entity{name=names.belt, position={13.5,2.5}, direction=north, force="player"}
				putItemsOnBelt(belt, names.cable)

				-- final merger
				surface.create_entity{name=names.merger, position={13.5,0.5}, direction=east, force="player"}
				buffer = surface.create_entity{name=names.splitterbox, position={13.5,0.5}, force="player"}
				createLoader({12.5,0.5}, east, 0, buffer, "input")
				createLoader({13.5,-0.5}, south, 1, buffer, "input")
				createLoader({13.5,1.5}, north, 1, buffer, "input")
				loader = createLoader({14.5,0.5}, east, 1, buffer, "output")
				putItemsOnBelt(loader.belt, names.cable)
				putItemsOnBelt(loader.belt, names.cable, true)
				for x=15.5,17.5,1 do
					belt = surface.create_entity{name=names.belt, position={x,0.5}, direction=east, force="player"}
					putItemsOnBelt(belt, names.wire)
					putItemsOnBelt(belt, names.wire, true)
				end

				-- infinity chest
				surface.create_entity{name=names.infinity, position={20.5,0.5}, direction=east, force="player"}
				buffer = surface.create_entity{name=names.infinitybox, position={20.5,0.5}, force="player"}
				buffer.remove_unfiltered_items = true
				createLoader({18.5,0.5}, east, 1, buffer, "input")
			]]
		}
	}
}
