-- uses global.onboarding to track freeplay-based story

local script_data = {
	step = 0,
	wait_until = 0
}

-- modify default freeplay scenario
local function onInit()
	if remote.interfaces.freeplay then
		global.onboarding = global.onboarding or script_data

		remote.call("freeplay","set_created_items",{
			["xeno-zapper"] = 1
		})
		remote.call("freeplay","set_respawn_items",{})
		remote.call("freeplay","set_skip_intro",true)
		remote.call("freeplay","set_disable_crashsite",true)
		remote.call("freeplay","set_chart_distance",1)
		if remote.interfaces['silo_script'] then
			remote.call("silo_script", "set_no_victory", true)
		end
		game.surfaces.nauvis.create_entity{
			name = "drop-pod",
			position = {0.5,-1.5},
			force = game.forces.player,
			raise_built = true
		}.minable = false
		game.forces.player.set_spawn_position({0.5,0.5}, game.surfaces.nauvis)
	else
		script_data.step = 999
		global.onboarding = script_data
	end
end
local function onPlayerCreated(event)
	local player = game.players[event.player_index]
	if script_data.step == 0 then
		player.print{"story-message.welcome-to-satisfactorio"}
		script_data.wait_until = event.tick < 10 and 60 or event.tick + 180 -- keep the first one short since resource spawning causes a delay anyway
	end
end

local messages = {
	"i-am-ada",
	"begin-onboarding",
	"first-objective",
	"second-objective",
	"third-objective",
	"hub-built", -- 6
	"fourth-objective",
	"fifth-objective",
	"sixth-objective",
	"seventh-objective",
	"eighth-objective",
	"ninth-objective",
	"congratulations", -- 13
	"additional-knowledge"
}

local function onSecond(event)
	if script_data.step < 100 and script_data.wait_until > 0 and script_data.wait_until < event.tick then
		script_data.step = script_data.step + 1
		if script_data.step > #messages then
			script_data.step = 999
		else
			game.forces.player.print{"story-message."..messages[script_data.step]}
			if script_data.step < 3 or script_data.step == 6 or script_data.step == 13 then
				script_data.wait_until = event.tick + 300
			else
				script_data.wait_until = 0 -- "pause"
			end

			if script_data.step == 3 then
				game.surfaces.nauvis.find_entity("drop-pod",{0.5,-1.5}).minable = true
			end
		end
	end
end

local function onMined(event)
	if event.entity.name == "drop-pod" and script_data.step == 3 and script_data.wait_until == 0 then
		script_data.wait_until = event.tick + 120
	end
	if event.entity.name == "iron-ore" and script_data.step == 4 and script_data.wait_until == 0 then
		script_data.wait_until = event.tick + 120
	end
end
local function onBuilt(event)
	if event.created_entity.name == "the-hub" and script_data.step <= 5 then
		-- if player builds HUB early, skip ahead
		script_data.step = 5
		script_data.wait_until = event.tick + 120
	end
end

local techs = {
	["hub-tier0-hub-upgrade-1"] = true,
	["hub-tier0-hub-upgrade-2"] = true,
	["hub-tier0-hub-upgrade-3"] = true,
	["hub-tier0-hub-upgrade-4"] = true,
	["hub-tier0-hub-upgrade-5"] = true,
	["hub-tier0-hub-upgrade-6"] = true
}
local function onResearch(event)
	if techs[event.research.name] and script_data.step < 100 then
		script_data.wait_until = event.tick + 300
	end
end

return {
	on_init = onInit,
	on_load = function()
		script_data = global.onboarding or script_data
	end,
	on_nth_tick = {
		[60] = onSecond
	},
	events = {
		[defines.events.on_player_created] = onPlayerCreated,
		[defines.events.on_player_mined_entity] = onMined,
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_research_finished] = onResearch
	}
}
