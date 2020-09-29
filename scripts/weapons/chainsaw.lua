-- chainsaw needs to respond to killing trees to trigger an "explosion" that kills more trees
-- it should also "mine" the trees rather than killing them

local function onKill(event)
	if not event.entity or not event.entity.valid then return end
	if not event.cause then return end
	if event.cause.type ~= "character" then return end
	if not event.damage_type then return end
	if event.damage_type.name ~= "chainsaw" then return end
	-- entity was killed by a chainsaw! Only possible on "chainsawable" entities
	local surface = event.entity.surface
	local position = event.entity.position
	local trees = surface.find_entities_filtered{
		position = position,
		radius = 5,
		type = "tree"
	}
	for _,tree in pairs(trees) do
		event.cause.mine_entity(tree, true)
	end
	local plants = surface.find_entities_filtered{
		position = position,
		radius = 5,
		name = {"paleberry","paleberry-harvested","beryl-nut","beryl-nut-harvested","bacon-agaric"}
	}
	for _,plant in pairs(plants) do
		event.cause.mine_entity(plant, true)
	end
end

return {
	events = {
		[defines.events.on_entity_died] = onKill
	}
}
