--- pshy_fasttime.lua
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
--
-- @require pshy_commands.lua
-- @require pshy_essentials.lua
-- @require pshy_help.lua
-- @require pshy_mapdb.lua
-- @require pshy_merge.lua



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
local best_time = nil
local best_player = nil



--- Tell the script a player exist.
function TouchPlayer(player_name)
end



function eventNewGame()
	if best_time then
		tfm.exec.chatMessage(string.format("<j><ch>%s</ch> won the map with a time of <ch2>%f</ch2> seconds.", best_player, best_time / 100))
		tfm.exec.setPlayerScore(best_player, 1, true)
	end
	best_time = nil
	best_player = nil
	tfm.exec.setGameTime(60 * 3 + 3)
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
	if best_time then
		tfm.exec.chatMessage(string.format("The current best time is <ch2>%f</ch2> by <n><ch>%s</ch>.", best_time / 100, best_player))
	end
end



function eventPlayerDied(player_name)
	tfm.exec.respawnPlayer(player_name)
end



function eventPlayerWon(player_name, time, time_since_respawn)
	if not best_time or time_since_respawn < best_time then
		best_player = player_name
		best_time = time_since_respawn
		tfm.exec.chatMessage(string.format("<n><ch>%s</ch> made a new best time of <ch2>%f</ch2> seconds.", best_player, best_time / 100))
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
	pshy.newgame_ChatCommandRotc(nil, "P7")
	tfm.exec.newGame()
end
