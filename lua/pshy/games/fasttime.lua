--- pshy.games.fasttime
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
pshy.require("pshy.alternatives.chat")
pshy.require("pshy.anticheats.antiguest")
pshy.require("pshy.anticheats.ban")
pshy.require("pshy.anticheats.loadersync")
pshy.require("pshy.bases.version")
pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.commands.list.game")
pshy.require("pshy.commands.list.players")
pshy.require("pshy.commands.list.modules")
pshy.require("pshy.commands.list.room")
pshy.require("pshy.commands.list.tfm")
pshy.require("pshy.essentials")
pshy.require("pshy.events")
pshy.require("pshy.help")
local help_pages = pshy.require("pshy.help.pages")
local newgame = pshy.require("pshy.rotations.newgame")
pshy.require("pshy.tools.motd")



--- help Page:
help_pages["fasttime"] = {back = "", title = "Fasttime", text = "Make the shortest time!\n", commands = {}}
help_pages[""].subpages["fasttime"] = help_pages["fasttime"]



--- TFM Settings:
tfm.exec.disableAfkDeath(true) 
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableAutoScore(true)
system.disableChatCommandDisplay(nil, true)
tfm.exec.disableAutoNewGame(true)



--- Internal Use:
local first_map_started = false
local best_time = nil
local best_player = nil
local last_win_order = 0
local player_times = {}
local player_win_order = {}
local pending_respawn = {}
local pending_respawn_2 = {}
local spawn_new_players = true



--- Tell the script a player exist.
function TouchPlayer(player_name)
	system.bindKeyboard(player_name, 46, false, true)
	ui.addTextArea(74984, "<p align='center'><font size='12'><a href='event:pcmd help fasttime'>help</a></font></p>", player_name, 5, 25, 40, 20, 0x111111, 0xFFFF00, 0.2, true)
end



function ResetTimes()
	best_time = nil
	best_player = nil
	player_times = {}
	player_win_order = {}
	last_win_order = 0
end



function ResetPlayerTime(player_name)
	player_times[player_name] = nil
	player_win_order[player_name] = nil
	if best_player ~= nil and best_player == player_name then
		best_time = nil
		best_player = nil
		best_win_order = nil
		for player_name, time in pairs(player_times) do
			if (not best_time) or (time < best_time) or (time == best_time and player_win_order[player_name] < best_win_order) then
				best_player = player_name
				best_time = time
				best_win_order = player_win_order[player_name]
			end
		end
		if best_player then
			ui.setShamanName(string.format("<ch>%s</ch> (<ch2>%f</ch2>)", best_player, best_time / 100))
		else
			ui.setShamanName("")
		end
	end
end



function eventKeyboard(player_name, keycode, down)
	if keycode == 46 and not down then
		tfm.exec.killPlayer(player_name)
	end
end



function eventNewGame()
	if best_time then
		tfm.exec.chatMessage(string.format("<fc><ch>%s</ch> won the round, with a time of <ch2>%f</ch2> seconds!", best_player, best_time / 100))
		tfm.exec.setPlayerScore(best_player, 1, true)
	else
		if first_map_started then
			tfm.exec.chatMessage("<fc>Nobody even made it?!")
		end
	end
	ResetTimes()
	tfm.exec.setGameTime(60 * 3 + 3)
	tfm.exec.chatMessage("<n>Make the shortest time to win the round!")
	first_map_started = true
	tfm.exec.setUIMapName("<fc>Fasttime")
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
	tfm.exec.chatMessage("<n>Make the shortest time to win the round!", player_name)
	if best_time then
		tfm.exec.chatMessage(string.format("<n>The current best time is <ch2>%f</ch2> by <n><ch>%s</ch>.", best_time / 100, best_player), player_name)
	end
	if spawn_new_players then
		tfm.exec.respawnPlayer(player_name)
	else
		tfm.exec.chatMessage("You will spawn on the next map.", player_name)
	end
end



function eventPlayerLeft(player_name)
	ResetPlayerTime(player_name)
end



function eventPlayerDied(player_name)
	table.insert(pending_respawn, player_name)
end



function eventPlayerWon(player_name, time, time_since_respawn)
	player_times[player_name] = player_times[player_name] or time_since_respawn
	if time_since_respawn < player_times[player_name] then
		player_times[player_name] = time_since_respawn
	end
	if not best_time or time_since_respawn < best_time then
		best_player = player_name
		best_time = time_since_respawn
		last_win_order = last_win_order + 1
		player_win_order[player_name] = last_win_order
		tfm.exec.chatMessage(string.format("<j><ch>%s</ch> made a new best time of <ch2>%f</ch2> seconds.", best_player, best_time / 100))
		ui.setShamanName(string.format("<ch>%s</ch> (<ch2>%f</ch2>)", best_player, best_time / 100))
	else
		if player_times[player_name] == time_since_respawn then
			tfm.exec.chatMessage(string.format("<n>Your time is <ch2>%f</ch2> seconds, this is your best time yet.", time_since_respawn / 100), player_name)
		else
			tfm.exec.chatMessage(string.format("<n>Your time is <ch2>%f</ch2> seconds.", time_since_respawn / 100), player_name)
		end
	end
	table.insert(pending_respawn, player_name)
end



function eventLoop(time, time_remaining)
	if #pending_respawn_2 > 0 then
		for i_died, player_name in ipairs(pending_respawn_2) do
			tfm.exec.respawnPlayer(player_name)
		end
		pending_respawn_2 = {}
	end
	if #pending_respawn > 0 then
		pending_respawn_2 = pending_respawn
		pending_respawn = {}
	end
	if time_remaining < 0 then
		tfm.exec.newGame()
	end
end



function eventInit()
	ResetTimes()
	for player_name, v in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
	newgame.SetRotation("P7")
	tfm.exec.newGame()
end



--- !rec
local function ChatCommandRec(user)
	if not best_time then
		return false, "Nobody made a time yet."
	end
	local additional
	if best_player == user then
		additional = " This is your time."
	else
		additional = player_times[user] and string.format(" Your best time is <ch2>%f</ch2>.", player_times[user] / 100) or ""
	end
	return true, string.format("The time to beat is <ch2>%f</ch2> seconds by <ch>%s</ch>.%s", best_time / 100, best_player, additional)
end
command_list["rec"] = {perms = "everyone", func = ChatCommandRec, desc = "See the best time yet.", argc_min = 0, argc_max = 0, arg_types = {}}
help_pages["fasttime"].commands["rec"] = command_list["rec"]



--- !rmtime
local function ChatCommandRmscore(user, target_player)
	ResetPlayerTime(target_player)
end
command_list["rmtime"] = {perms = "admins", func = ChatCommandRmscore, desc = "Erase a player's score.", argc_min = 1, argc_max = 1, arg_types = {"player"}}
help_pages["fasttime"].commands["rmtime"] = command_list["rmtime"]



--- !spawnnewplayers
local function ChatCommandRmscore(user, enabled)
	spawn_new_players = enabled
	if enabled then
		return true, "New players will be able to play on the current map."
	else
		return true, "New players need to wait the next map."
	end
end
command_list["spawnnewplayers"] = {perms = "admins", func = ChatCommandRmscore, desc = "Erase a player's score.", argc_min = 1, argc_max = 1, arg_types = {"boolean"}}
help_pages["fasttime"].commands["spawnnewplayers"] = command_list["spawnnewplayers"]
