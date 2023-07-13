--- pshy.tools.afks
--
-- Find afk players.
--
-- Times at which players were last active are set in `afks.active_times`
-- After 60 seconds of innactivity, players are being warned they are considered afk.
-- You should consider players afk after 90 seconds of innactivity.
--
-- /!\ Keyboard key down events are used to know when a player is not afk, bind the keys yourself.
-- If you do not do that, chat messages and emotes will be relied upon.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local events = pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local ids = pshy.require("pshy.utils.ids")
local os_time = os.time



--- Namespace.
local afks = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Dbg Evnt Timing"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal use:
local time_before_afk = 60 * 1000
local textarea_id = ids.AllocTextAreaId()
local last_afk_check = os_time()



--- Last active times and afk start times.
local player_last_active_times = {}
local players_displayed_afk = {}
afks.active_times = player_last_active_times



--- Set a player as not afk.
local function NotAfk(player_name)
	if players_displayed_afk[player_name] then
		players_displayed_afk[player_name] = nil
		tfm.exec.chatMessage("You are no longer afk.", player_name)
		ui.removeTextArea(textarea_id, player_name)
	end
	assert(player_name ~= nil, "player_name is nil")
	player_last_active_times[player_name] = os_time()
end



--- Check who is afk.
local function CheckAfks()
	local current_time = os_time()
	for player_name, last_active_time in pairs(player_last_active_times) do
		if current_time - last_active_time > time_before_afk then
			if not players_displayed_afk[player_name] then
				tfm.exec.chatMessage("You are now afk.", player_name)
				ui.addTextArea(textarea_id, "<r><b>You are AFK.</b>\nPlay an emote when you are back.</r>", player_name, 20, 80, nil, nil, 0, 0, 0, true)
				players_displayed_afk[player_name] = true
			end
		end
	end
end



local function TouchPlayer(player_name)
	player_last_active_times[player_name] = os_time()
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventPlayerLeft(player_name)
	player_last_active_times[player_name] = nil
	players_displayed_afk[player_name] = nil
end



function eventChatMessage(player_name)
	NotAfk(player_name)
end



function eventPopupAnswer(popup_id, player_name)
	NotAfk(player_name)
end



function eventEmotePlayed(player_name)
	NotAfk(player_name)
end



function eventPlayerMeep(player_name)
	NotAfk(player_name)
end



function eventKeyboard(player_name, keycode, down)
	-- @TODO: This is efficient but expenssive. May be replaced by a check on player direction facing changes.
	if down then
		NotAfk(player_name)
	end
end



function eventLoop()
	if os_time() - last_afk_check > 3000 then
		CheckAfks()
		last_afk_check = os_time()
	end
end



function eventInit()
	for player_name, player in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end



__MODULE__.commands = {
	["afks"] = {
		desc = "Show the longest afks players.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			local player_afk_times = {}
			local numeric_afk_times = {}
			local current_time = os_time()
			for player_name, last_active_time in pairs(player_last_active_times) do
				local afk_time = current_time - last_active_time
				if afk_time > 70000 then
					player_afk_times[player_name] = afk_time
					table.insert(numeric_afk_times, #numeric_afk_times + 1, afk_time)
				end
			end
			if #numeric_afk_times == 0 then
				return false, "No afk player."
			end
			table.sort(numeric_afk_times)
			local worst_times_limit = numeric_afk_times[math.min(10, #numeric_afk_times)]
			tfm.exec.chatMessage("<vp>Top Afk Players: </vp>", user)
			for player_name, afk_time in pairs(player_afk_times) do
				local afk_mins = afk_time / 1000 / 60
				local afk_secs = (afk_time / 1000) - (math.floor(afk_mins) * 60)
				local afk_color_markup = "<vp>"
				if afk_mins > 20 then
					afk_color_markup = "<r>"
				elseif afk_mins > 10 then
					afk_color_markup = "<o>"
				elseif afk_mins > 2 then
					afk_color_markup = "<j>"
				end
				tfm.exec.chatMessage(string.format("  <bl>%s</bl>\t - %s%d mins %d secs", player_name, afk_color_markup, afk_mins, afk_secs), user)
			end
			return true
		end
	}
}



return afks
