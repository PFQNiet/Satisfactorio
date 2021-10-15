---@class PingTarget
---@field surface LuaSurface
---@field position Position
---@field sprite SpritePath

---@class PingData
---@field id uint
---@field player LuaPlayer
---@field target LuaEntity|PingTarget
---@field sprite SpritePath
---@field graphics uint64[]

-- uses global.pings as table of active pings
local util = require("util")

---@class global.pings
---@field pings PingData[]
---@field auto_increment uint
local script_data = {
	pings = {},
	auto_increment = 0
}

--- Determine if the target is an entity or custom target and return the sprite accordingly
---@param target LuaEntity|PingTarget
---@return SpritePath
local function getSpriteForTarget(target)
	return target.object_name == "LuaEntity" and "entity/"..target.name or target.sprite
end

--- Add a tracking ping and return its unique ID
---@param player LuaPlayer
---@param target LuaEntity|PingTarget
---@return uint
local function addPing(player, target)
	if not target then return end
	if target.object_name == "LuaEntity" and not target.valid then return end

	local index = script_data.auto_increment + 1
	script_data.auto_increment = index

	local sprite = getSpriteForTarget(target)
	---@type PingData
	local struct = {
		id = index,
		player = player,
		target = target,
		sprite = sprite,
		graphics = {}
	}
	script_data.pings[index] = struct
	return index
end

--- Destroy a tracking ping
---@param id uint An ID returned by addPing
local function deletePing(id)
	local struct = script_data.pings[id]
	if not struct then return end
	for _,graphic in pairs(struct.graphics) do
		if rendering.is_valid(graphic) then
			rendering.destroy(graphic)
		end
	end
	script_data.pings[id] = nil
end

--- Update a ping's target
---@param id uint An ID returned by addPing
---@param target LuaEntity|PingTarget
local function updatePingTarget(id, target)
	local struct = script_data.pings[id]
	if not struct then return end
	if not target then return end
	if target.object_name == "LuaEntity" and not target.valid then return end
	local sprite = getSpriteForTarget(target)
	struct.target = target
	if struct.sprite ~= sprite then
		rendering.set_sprite(struct.graphics.item, sprite)
	end
	struct.sprite = sprite
end

--- Determine if a ping ID is valid
---@param id uint An ID returned by addPing
---@return boolean
local function isValid(id)
	local struct = script_data.pings[id]
	if struct then return true end
	return false
end

local function onTick()
	for _,ping in pairs(script_data.pings) do
		local player = ping.player
		local target = ping.target
		local graphics = ping.graphics
		if target.object_name == "LuaEntity" and not target.valid then
			deletePing(ping.id)
		else
			local playerpos = player.position
			local targetpos = target.position
			local playersurf = player.surface
			if playersurf ~= target.surface then
				deletePing(ping.id)
			else
				if not (graphics.background and rendering.is_valid(graphics.background)) then
					-- likely first-time setup, or graphics were lost for some reason
					graphics.background = rendering.draw_sprite{
						sprite = "resource-scanner-ping",
						target = playerpos,
						surface = playersurf,
						players = {player}
					}
					graphics.item = rendering.draw_sprite{
						sprite = ping.sprite,
						target = playerpos,
						surface = playersurf,
						players = {player}
					}
					graphics.arrow = rendering.draw_sprite{
						sprite = "utility/indication_arrow",
						target = playerpos,
						surface = playersurf,
						players = {player}
					}
					graphics.label = rendering.draw_text{
						text = {"gui.resource-scanner-distance","-"},
						color = {1,1,1},
						alignment = "center",
						target = playerpos,
						surface = playersurf,
						players = {player}
					}
				end

				local dx = targetpos.x - playerpos.x
				local dy = playerpos.y - targetpos.y
				local distance_from_player = 7
				local transition_ring = 3
				local distance = math.sqrt(dx*dx+dy*dy)+1
				local direction = math.atan2(dy,dx)
				local ping_angle
				local ping_position
				if distance < distance_from_player - transition_ring + 2 then
					-- it's very close, point straight down at it

					ping_angle = -math.pi/2
					ping_position = {targetpos.x, targetpos.y-1}
				elseif distance < distance_from_player + 2 then
					-- point at target but interpolate angle

					-- 0 = direction, 1 = straight down
					local lerp = ((distance_from_player+2)-distance)/transition_ring
					-- top-left quadrant needs to go the other way
					local down_angle = direction > math.pi/2 and 3*math.pi/2 or -math.pi/2
					ping_angle = direction + (down_angle-direction) * lerp
					ping_position = {targetpos.x - math.cos(ping_angle), targetpos.y + math.sin(ping_angle)}
				else
					-- it's far away, point into the distance

					ping_angle = direction
					ping_position = {playerpos.x + distance_from_player * math.cos(ping_angle), playerpos.y - distance_from_player * math.sin(ping_angle)}
				end

				rendering.set_target(graphics.background, ping_position)
				rendering.set_target(graphics.item, ping_position)
				rendering.set_target(graphics.arrow, {ping_position[1] + math.cos(ping_angle), ping_position[2] - math.sin(ping_angle)})
				rendering.set_orientation(graphics.arrow, 0.25 - ping_angle/math.pi/2)
				rendering.set_target(graphics.label, {ping_position[1], ping_position[2] + 0.25})
				rendering.set_text(graphics.label, {"gui.object-scanner-distance", util.format_number(math.floor(distance))})
			end
		end
	end
end

-- on changing surface, all pings for the given player are invalidated
---@param event on_player_changed_surface
local function onSurfaceChange(event)
	local player = game.players[event.player_index]
	for _,ping in pairs(script_data.pings) do
		if ping.player == player then
			deletePing(ping.id)
		end
	end
end

return {
	addPing = addPing,
	deletePing = deletePing,
	updatePingTarget = updatePingTarget,
	isValid = isValid,
	lib = {
		on_init = function()
			global.pings = global.pings or script_data
		end,
		on_load = function()
			script_data = global.pings or script_data
		end,
		add_commands = function()
			if not commands.commands['clear-pings'] then
				commands.add_command("clear-pings",{"command.clear-pings"},function(event)
					local player = game.players[event.player_index]
					for i,ping in pairs(script_data.pings) do
						if ping.player == player then
							deletePing(i)
						end
					end
				end)
			end
		end,
		events = {
			[defines.events.on_tick] = onTick,
			[defines.events.on_player_changed_surface] = onSurfaceChange
		}
	}
}
