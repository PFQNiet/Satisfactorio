local handler = require("event_handler")

handler.add_lib(require("scripts.freeplay"))
handler.add_lib(require("scripts.indestructible"))
handler.add_libraries(require("scripts.constructors"))
handler.add_libraries(require("scripts.miners"))
handler.add_lib({
	on_init = function()
		local resources = {"coal","stone","iron-ore","copper-ore","uranium-ore","crude-oil","caterium-ore"}
		for i, res in ipairs(resources) do
			for dx = 0, 2 do
				for dy = 0, 2 do
					game.surfaces.nauvis.create_entity{
						name = res,
						position = {i*6+dx, -6+dy},
						force = game.forces.neutral,
						amount = 60
					}
					game.surfaces.nauvis.create_entity{
						name = res,
						position = {i*6+dx, 0+dy},
						force = game.forces.neutral,
						amount = 120
					}
					game.surfaces.nauvis.create_entity{
						name = res,
						position = {i*6+dx, 6+dy},
						force = game.forces.neutral,
						amount = 240
					}
				end
			end
		end
	end
})
