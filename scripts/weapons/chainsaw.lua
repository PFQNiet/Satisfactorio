-- chainsaw needs to respond to killing trees to trigger an "explosion" that kills more trees
-- it should also "mine" the trees rather than killing them

local function onKill(event)
	if not event.entity or not event.entity.valid then return end
	if event.entity.type ~= "tree" then return end
	if not event.cause then return end
	if event.cause.type ~= "character" then return end
	if not event.damage_type then return end
	if event.damage_type.name ~= "chainsaw" then return end
	-- tree was killed by a chainsaw!
	local inventory = game.create_inventory(100)
	local trees = event.entity.surface.find_entities_filtered{
		position = event.entity.position,
		radius = 5,
		type = "tree"
	}
	for _,tree in pairs(trees) do
		event.cause.mine_entity(tree, true)
	end
end

return {
	events = {
		[defines.events.on_entity_died] = onKill
	}
}
