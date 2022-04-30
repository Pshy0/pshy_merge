--- pshy_fasttime.lua
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
--
-- @require pshy_antiguest.lua
-- @require pshy_commands.lua
-- @require pshy_commands_tfm.lua
-- @require pshy_essentials.lua
-- @require pshy_help.lua
-- @require pshy_mapdb.lua
-- @require pshy_merge.lua
-- @require pshy_newgame.lua
-- @require pshy_version.lua



--- help Page:
pshy.help_pages["fasttime"] = {back = "", title = "Fasttime", text = "Make the shortest time!\n", commands = {}}
pshy.help_pages[""].subpages["fasttime"] = pshy.help_pages["fasttime"]



--- TFM Settings:
tfm.exec.disableAfkDeath(true) 
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableAutoScore(true)
system.disableChatCommandDisplay(nil, true)



--- Internal Use:
local first_map_started = false
local best_time = nil
local best_player = nil



--- Tell the script a player exist.
function TouchPlayer(player_name)
	system.bindKeyboard(player_name, 46, false, true)
	ui.addTextArea(74984, "<p align='center'><font size='12'><a href='event:pcmd help fasttime'>help</a></font></p>", player_name, 5, 25, 40, 20, 0x111111, 0xFFFF00, 0.2, true)
end



function eventKeyboard(player_name, keycode)
	if keycode == 46 then
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
	best_time = nil
	best_player = nil
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
	tfm.exec.respawnPlayer(player_name)
end



function eventPlayerDied(player_name)
	tfm.exec.respawnPlayer(player_name)
end



function eventPlayerWon(player_name, time, time_since_respawn)
	if not best_time or time_since_respawn < best_time then
		best_player = player_name
		best_time = time_since_respawn
		tfm.exec.chatMessage(string.format("<j><ch>%s</ch> made a new best time of <ch2>%f</ch2> seconds.", best_player, best_time / 100))
		ui.setShamanName(string.format("<ch>%s</ch> (<ch2>%f</ch2>)", best_player, best_time / 100))
	else
		tfm.exec.chatMessage(string.format("<n>Your time is <ch2>%f</ch2> seconds.", time_since_respawn / 100), player_name)
	end
	tfm.exec.respawnPlayer(player_name)
end



--- !rec
local function ChatCommandRec(user, level)
	if not best_time then
		return false, "Nobody made a time yet."
	end
	return true, string.format("The time to beat is <ch2>%f</ch2> seconds by <ch>%s</ch>.", best_time / 100, best_player)
end
pshy.commands["rec"] = {func = ChatCommandRec, desc = "See the best time yet.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["fasttime"].commands["rec"] = pshy.commands["rec"]
pshy.perms.everyone["!rec"] = true



function eventInit()
	for player_name, v in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
	pshy.newgame_SetRotation("P7")
	tfm.exec.newGame()
end
