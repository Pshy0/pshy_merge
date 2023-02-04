--- pshy.debug.playerdump
--
-- Print a player's table and queue them for printing on win/death and on next loop.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.utils.print")



--- Module Help Page:
help_pages["pshy.debug.playerdump"] = {back = "pshy", title = "Dbg Plyr Dump", commands = {}}
help_pages["pshy"].subpages["pshy.debug.playerdump"] = help_pages["pshy.debug.playerdump"]



local players_to_dump_on_win_or_death = {}
local players_to_dump_next_loop = {}



local function DumpPlayer(player_name, message)
	local tfm_player = tfm.get.room.playerList[player_name]
	if not tfm_player then
		print_error("DumpPlayer: Player %s not found!", player_name)
		return
	end
	local text = ""
	text = text .. string.format("\t\tx:  %4d\ty:  %4d\n", tfm_player.x, tfm_player.y)
	text = text .. string.format("\t\tvx: %4d\tvy: %4d\n", tfm_player.vx, tfm_player.vy)
	text = text .. string.format("\t\tisDead: %s\n", tostring(tfm_player.isDead))
	text = text .. string.format("\t\thasCheese: %s\tcheeses: %d\n", tostring(tfm_player.hasCheese), tfm_player.cheeses)
	text = text .. string.format("\t\tisJumping: %s\n", tostring(tfm_player.isJumping))
	text = text .. string.format("\t\tmovingLeft: %s movingRight: %s\n", tostring(tfm_player.movingLeft), tostring(tfm_player.movingRight))
	text = text .. string.format("\t\tisFacingRight:  %s\n", tostring(tfm_player.isFacingRight))
	text = text .. string.format("\t\taverageLatency: %d", tfm_player.averageLatency)
	print_debug(message .. "\n" .. text)
end



function eventPlayerWon(player_name)
	if players_to_dump_on_win_or_death[player_name] then
		DumpPlayer(player_name, string.format("<vp>Dump of player %s (eventPlayerWon):", player_name))
		players_to_dump_on_win_or_death[player_name] = nil
		players_to_dump_next_loop[player_name] = true
	end
end



function eventPlayerDied(player_name)
	if players_to_dump_on_win_or_death[player_name] then
		DumpPlayer(player_name, string.format("<r>Dump of player %s (eventPlayerDied):", player_name))
		players_to_dump_on_win_or_death[player_name] = nil
		players_to_dump_next_loop[player_name] = true
	end
end



function eventNewGame()
	players_to_dump_on_win_or_death = {}
	players_to_dump_next_loop = {}
end



function eventLoop()
	for player_name in pairs(players_to_dump_next_loop) do
		DumpPlayer(player_name, string.format("<j>Dump of player %s (eventLoop):", player_name))
	end
	players_to_dump_next_loop = {}
end



--- !playerdump
local function ChatCommandPlayerdump(user, player_name)
	players_to_dump_on_win_or_death[player_name] = true
	DumpPlayer(player_name, string.format("<ch>Dump of player %s (!playerdump):", player_name))
	return true
end
command_list["playerdump"] = {perms = "admins", aliases = {"pd"},func = ChatCommandPlayerdump, desc = "Dump some player fields now and when they win or die.", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy.debug.playerdump"].commands["playerdump"] = command_list["playerdump"]
