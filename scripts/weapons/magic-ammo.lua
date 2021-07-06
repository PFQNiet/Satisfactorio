local guns_and_ammo = {
	["xeno-zapper"] = "xeno-zapper-ammo",
	["xeno-basher"] = "xeno-basher-ammo"
}
local ammo_and_guns = {}
for g,a in pairs(guns_and_ammo) do ammo_and_guns[a] = g end

---@param player LuaPlayer
local function fix_ammo(player)
	local guns = player.get_inventory(defines.inventory.character_guns)
	local ammo = player.get_inventory(defines.inventory.character_ammo)
	if not (guns and ammo) then return end
	for i=1,#guns do
		if guns[i].valid_for_read then
			local expect = guns_and_ammo[guns[i].name]
			if expect and (not ammo[i].valid_for_read or ammo[i].name ~= expect) then
				ammo[i].set_stack{name=expect, count=1}
			end
		elseif ammo[i].valid_for_read then
			if ammo_and_guns[ammo[i].name] then
				ammo[i].clear()
			end
		end
	end
end

---@param player LuaPlayer
local function remove_ammo(player)
	local main = player.get_inventory(defines.inventory.character_main)
	if not main then return end
	for ammo in pairs(ammo_and_guns) do
		main.remove{name=ammo,count=1000000}
	end
end

---@param player LuaPlayer
local function no_touching(player)
	local cursor = player.cursor_stack
	if not cursor.valid_for_read then return end
	for ammo in pairs(ammo_and_guns) do
		if cursor.name == ammo then
			cursor.clear()
			return
		end
	end
end

---@param corpse LuaEntity CharacterCorpse
local function clean_corpse(corpse)
	local remains = corpse.get_inventory(defines.inventory.character_corpse)
	if not remains then return end
	for ammo in pairs(ammo_and_guns) do
		remains.remove{name=ammo,count=1000000}
	end
end

return {
	events = {
		[defines.events.on_player_gun_inventory_changed] = function(event)
			local player = game.players[event.player_index]
			fix_ammo(player)
		end,
		[defines.events.on_player_ammo_inventory_changed] = function(event)
			local player = game.players[event.player_index]
			remove_ammo(player)
			fix_ammo(player)
		end,
		[defines.events.on_player_cursor_stack_changed] = function(event)
			local player = game.players[event.player_index]
			no_touching(player)
			remove_ammo(player)
			fix_ammo(player)
		end,
		[defines.events.on_post_entity_died] = function(event)
			if event.prototype.name == "character" and event.corpses[1] then
				clean_corpse(event.corpses[1])
			end
		end
	}
}
