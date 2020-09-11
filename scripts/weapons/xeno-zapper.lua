local name = "xeno-zapper"

local function fix_ammo(player)
	local guns = player.get_inventory(defines.inventory.character_guns)
	if not guns then return end
	local ammo = player.get_inventory(defines.inventory.character_ammo)
	if not ammo then return end
	for i=1,#guns do
		if guns[i].valid_for_read and guns[i].name == name then
			if not ammo[i].valid_for_read or ammo[i].name ~= name.."-ammo" then
				ammo[i].set_stack({name=name.."-ammo",count=1})
			end
		elseif ammo[i].valid_for_read and ammo[i].name == name.."-ammo" then
			ammo[i].clear()
		end
	end
end
local function remove_ammo(player)
	local main = player.get_inventory(defines.inventory.character_main)
	if not main then return end
	main.remove({name=name.."-ammo",count=1000000}) -- no kill like overkill - make really damn sure no magic ammo ends up in the player's inventory
end
local function no_touching(player)
	local cursor = player.cursor_stack
	if not cursor.valid_for_read then return end
	if cursor.name == name.."-ammo" then
		cursor.clear()
	end
end
local function clean_corpse(corpse)
	local remains = corpse.get_inventory(defines.inventory.character_corpse)
	if not remains then return end
	remains.remove({name=name.."-ammo",count=1000000})
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
