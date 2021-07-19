local event_handler = require "event_handler"
local gui = require(modpath.."scripts.gui.onboarding")

-- track story progress in freeplay
---@class global.onboarding
---@field step uint
---@field wait_until uint Tick number on which to proceed to the next step
---@field message LocalisedString
local script_data = {
	step = 0,
	wait_until = 0,
	message = ""
}

local messages = {
	"welcome-to-satisfactorio",
	"i-am-ada",
	"begin-onboarding",
	"first-objective", -- dismantle drop pod
	"second-objective", -- find iron ore
	"third-objective", -- build HUB
	"hub-built", -- 7
	"fourth-objective", -- complete hub upgrades 1-6
	"fifth-objective",
	"sixth-objective",
	"seventh-objective",
	"eighth-objective",
	"ninth-objective",
	"congratulations", -- 14
	"additional-knowledge"
}
-- steps that have a "continue" button for the player to click
local function isContinuable(step)
	return step < 4 or step == 7 or step >= 14
end

-- modify default freeplay scenario
local function onInit()
	if remote.interfaces['silo_script'] then
		remote.call("silo_script", "set_no_victory", true)
	end
	if remote.interfaces.freeplay then
		global.onboarding = global.onboarding or script_data

		remote.call("freeplay","set_created_items",{
			["xeno-zapper"] = 1
		})
		remote.call("freeplay","set_respawn_items",{})
		remote.call("freeplay","set_skip_intro",true)
		remote.call("freeplay","set_disable_crashsite",true)
		remote.call("freeplay","set_chart_distance",1)
		for _,tree in pairs(game.surfaces.nauvis.find_entities_filtered{
			type = "tree",
			position = {0,0},
			radius = 10
		}) do
			tree.destroy()
		end
		game.surfaces.nauvis.create_entity{
			name = "drop-pod",
			position = {0.5,-1.5},
			force = game.forces.player,
			raise_built = true
		}.minable = false
		game.forces.player.set_spawn_position({0.5,0.5}, game.surfaces.nauvis)

		script_data.step = 0
		script_data.wait_until = 120
	else
		script_data.step = 999
		global.onboarding = script_data
	end
end

---@param event on_player_created
local function onPlayerCreated(event)
	local player = game.players[event.player_index]
	gui.update(player, script_data.message, isContinuable(script_data.step))
end

---@param message LocalisedString
---@param button boolean
local function setMessage(message, button)
	script_data.message = message
	for _,player in pairs(game.forces.player.players) do
		gui.update(player, message, button)
		player.force.play_sound{path = "utility/new_objective"}
	end
end

local function onSecond()
	if script_data.step < 100 and script_data.wait_until > 0 and script_data.wait_until <= game.tick then
		script_data.step = script_data.step + 1
		if script_data.step > #messages then
			setMessage("")
			script_data.step = 999
		else
			setMessage({"story-message."..messages[script_data.step]}, isContinuable(script_data.step))
			script_data.wait_until = 0 -- "pause"

			if script_data.step == 4 then
				game.surfaces.nauvis.find_entity("drop-pod",{0.5,-1.5}).minable = true
			elseif script_data.step == 5 then
				game.forces.player.technologies['tips-and-tricks-melee-combat'].researched = true
			elseif script_data.step == 6 then
				game.forces.player.technologies['tips-and-tricks-build-gun'].researched = true
			end
		end
	end
end

---@param player LuaPlayer
gui.callbacks.continue = function(player)
	if isContinuable(script_data.step) and script_data.wait_until == 0 then
		script_data.wait_until = game.tick
		onSecond()
	end
end

local function onMined(event)
	if event.entity.name == "drop-pod" and script_data.step == 4 and script_data.wait_until == 0 then
		script_data.wait_until = event.tick + 120
	end
	if (event.entity.name == "iron-ore" or event.entity.name == "rock-big-iron-ore") and script_data.step == 5 and script_data.wait_until == 0 then
		script_data.wait_until = event.tick + 120
	end
end

local function onBuilt(event)
	if event.created_entity.name == "the-hub" and script_data.step <= 6 then
		-- if player builds HUB early, skip ahead
		script_data.step = 6
		script_data.wait_until = event.tick + 120
	end
end

local techs = {
	["hub-tier0-hub-upgrade1"] = 8,
	["hub-tier0-hub-upgrade2"] = 9,
	["hub-tier0-hub-upgrade3"] = 10,
	["hub-tier0-hub-upgrade4"] = 11,
	["hub-tier0-hub-upgrade5"] = 12,
	["hub-tier0-hub-upgrade6"] = 13
}
local function onResearch(event)
	if techs[event.research.name] and script_data.step <= techs[event.research.name] then
		script_data.step = techs[event.research.name]
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
