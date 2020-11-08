-- point out the player's corpse(s)
-- uses global.corpse_scanner.pings as table of player => {target, graphics} for active pings
local util = require("util")

local script_data = {
	pings = {}
}

local function playerDied(corpse)
	local player = game.players[corpse.character_corpse_player_index]
	if not script_data.pings[player.index] then script_data.pings[player.index] = {} end
	table.insert(script_data.pings[player.index], {target=corpse})
end

local function onTick(event)
	for pid,pings in pairs(script_data.pings) do
		local player = game.players[pid]
		for i,ping in pairs(pings) do
			if not (ping.target and ping.target.valid) then
				if ping.graphics then
					for _,rid in pairs(ping.graphics) do
						if rendering.is_valid(rid) then
							rendering.destroy(rid)
						end
					end
				end
				table.remove(pings,i)
			else
				if ping.graphics and (not rendering.is_valid(ping.graphics.background) or not ping.target or not ping.target.valid or ping.target.surface ~= player.surface) then
					-- changed surface
					for _,rid in pairs(ping.graphics) do
						if rendering.is_valid(rid) then
							rendering.destroy(rid)
						end
					end
					ping.graphics = nil
				end
				if ping.target and ping.target.valid and ping.target.surface == player.surface then
					if not ping.graphics then
						ping.graphics = {
							background = rendering.draw_sprite{
								sprite = "resource-scanner-ping",
								target = player.position,
								surface = player.surface,
								players = {player}
							},
							item = rendering.draw_sprite{
								sprite = "entity/"..ping.target.name,
								target = player.position,
								surface = player.surface,
								players = {player}
							},
							arrow = rendering.draw_sprite{
								sprite = "utility/indication_arrow",
								orientation = 0,
								target = player.position,
								surface = player.surface,
								players = {player}
							},
							label = rendering.draw_text{
								text = {"gui.resource-scanner-distance","-"},
								color = {1,1,1},
								surface = player.surface,
								target = player.position,
								players = {player},
								alignment = "center"
							}
						}
					end

					local dx = ping.target.position.x - player.position.x
					local dy = player.position.y - ping.target.position.y
					local dist = 7 -- ping distance around the player
					local ring = 3 -- thickness of "transition" ring between pointing away and pointing at target
					local distance = math.sqrt(dx*dx+dy*dy)+1
					local direction = math.atan2(dy,dx)
					if distance < dist-ring+2 then
						rendering.set_target(ping.graphics.background, {ping.target.position.x, ping.target.position.y-1})
						rendering.set_target(ping.graphics.item, {ping.target.position.x, ping.target.position.y-1})
						rendering.set_target(ping.graphics.arrow, ping.target.position)
						rendering.set_orientation(ping.graphics.arrow, 0.5)
						rendering.set_target(ping.graphics.label, {ping.target.position.x, ping.target.position.y-0.75})
					elseif distance < dist+2 then
						-- point at target but interpolate angle
						local lerp = ((dist+2)-distance)/ring -- at 1 it's pointing straight down, at 0 it's pointing in "direction"
						local target = direction > math.pi/2 and 3*math.pi/2 or -math.pi/2 -- top-left quadrant needs to go the other way
						local angle = direction + (target-direction)*lerp
						local offset = {
							math.cos(angle),
							-math.sin(angle)
						}
						rendering.set_target(ping.graphics.background, {ping.target.position.x-offset[1], ping.target.position.y-offset[2]})
						rendering.set_target(ping.graphics.item, {ping.target.position.x-offset[1], ping.target.position.y-offset[2]})
						rendering.set_target(ping.graphics.arrow, ping.target.position)
						rendering.set_orientation(ping.graphics.arrow, 0.25 - angle / math.pi/2)
						rendering.set_target(ping.graphics.label, {ping.target.position.x-offset[1], ping.target.position.y-offset[2]+0.25})
					else
						local offset = {
							math.cos(direction),
							-math.sin(direction)
						}
						rendering.set_target(ping.graphics.background, {player.position.x+offset[1]*dist, player.position.y+offset[2]*dist})
						rendering.set_target(ping.graphics.item, {player.position.x+offset[1]*dist, player.position.y+offset[2]*dist})
						rendering.set_target(ping.graphics.arrow, {player.position.x+offset[1]*(dist+1), player.position.y+offset[2]*(dist+1)})
						rendering.set_orientation(ping.graphics.arrow, 0.25 - direction / math.pi/2)
						rendering.set_target(ping.graphics.label, {player.position.x+offset[1]*dist, player.position.y+offset[2]*dist+0.25})
					end
					rendering.set_text(ping.graphics.label, {"gui.object-scanner-distance", util.format_number(math.floor(distance))})
				end
			end
		end
	end
end

return {
	on_init = function()
		global.corpse_scanner = global.corpse_scanner or script_data
	end,
	on_load = function()
		script_data = global.corpse_scanner or script_data
	end,
	on_configuration_changed = function()
		if global['corpse-pings'] then
			global.corpse_scanner.pings = table.deepcopy(global['corpse-pings'])
			global['corpse-pings'] = nil
		end
	end,
	events = {
		[defines.events.on_tick] = onTick,
		[defines.events.on_post_entity_died] = function(event)
			if event.prototype.name == "character" and event.corpses[1] then
				playerDied(event.corpses[1])
			end
		end
	}
}
