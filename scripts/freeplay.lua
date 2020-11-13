-- uses global.onboarding to track freeplay-based story

local script_data = {
	step = 0,
	wait_until = 0,
	message = ""
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
	local gui = player.gui.left.add{
		type = "frame",
		name = "onboarding",
		style = "goal_frame",
		caption = {"story-message.title"}
	}
	local frame = gui.add{
		type = "frame",
		name = "content",
		direction = "vertical",
		style = "goal_inner_frame"
	}
	frame.add{
		type = "label",
		name = "goal_text",
		style = "goal_label",
		caption = script_data.message
	}
	local flow = frame.add{
		type = "flow",
		name = "continue_button_flow",
		direction = "horizontal"
	}
	flow.style.top_margin = 8
	flow.add{
		type = "empty-widget"
	}.style.horizontally_stretchable = true
	flow.add{
		type = "button",
		style = "confirm_button",
		name = "story-continue-button",
		caption = {"story-message.continue"}
	}
	flow.visible = script_data.step < 4 or script_data.step == 7 or script_data.step == 14
	gui.visible = script_data.message ~= ""

	if script_data.step == 0 and script_data.wait_until == 0 then
		script_data.wait_until = event.tick < 10 and 60 or event.tick + 180 -- keep the first one short since resource spawning causes a delay anyway
	end
end

local messages = {
	"welcome-to-satisfactorio",
	"i-am-ada",
	"begin-onboarding",
	"first-objective",
	"second-objective",
	"third-objective",
	"hub-built", -- 7
	"fourth-objective",
	"fifth-objective",
	"sixth-objective",
	"seventh-objective",
	"eighth-objective",
	"ninth-objective",
	"congratulations", -- 14
	"additional-knowledge"
}

local function setMessage(message, button)
	script_data.message = message
	for _,player in pairs(game.forces.player.players) do
		local gui = player.gui.left.onboarding.content
		local flow = gui.continue_button_flow
		if message == "" then
			gui.parent.visible = false
		else
			gui.parent.visible = true
			gui.goal_text.caption = message
			flow.visible = button
			player.play_sound{path = "utility/new_objective"}
		end
	end
end

local function onSecond(event)
	if script_data.step < 100 and script_data.wait_until > 0 and script_data.wait_until <= event.tick then
		script_data.step = script_data.step + 1
		if script_data.step > #messages then
			setMessage("")
			script_data.step = 999
		else
			setMessage({"story-message."..messages[script_data.step]}, script_data.step < 4 or script_data.step == 7 or script_data.step == 14)
			script_data.wait_until = 0 -- "pause"

			if script_data.step == 4 then
				game.surfaces.nauvis.find_entity("drop-pod",{0.5,-1.5}).minable = true
			end
		end
	end
end

local function onGuiClick(event)
	if event.element and event.element.valid and event.element.name == "story-continue-button" and script_data.wait_until == 0 then
		-- double-check it's a continuable step
		if script_data.step < 4 or script_data.step == 7 or script_data.step == 14 then
			script_data.wait_until = event.tick
			onSecond(event) -- process it immediately
		end
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
	["hub-tier0-hub-upgrade-1"] = 8,
	["hub-tier0-hub-upgrade-2"] = 9,
	["hub-tier0-hub-upgrade-3"] = 10,
	["hub-tier0-hub-upgrade-4"] = 11,
	["hub-tier0-hub-upgrade-5"] = 12,
	["hub-tier0-hub-upgrade-6"] = 13
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
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_player_mined_entity] = onMined,
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_research_finished] = onResearch
	}
}
