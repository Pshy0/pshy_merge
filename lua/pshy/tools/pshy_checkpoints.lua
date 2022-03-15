--- pshy_checkpoints.lua
--
-- Adds respawn features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua



--- Module Help Page:
pshy.help_pages["pshy_checkpoints"] = {back = "pshy", title = "Checkpoints", text = nil, commands = {}}
pshy.help_pages["pshy"].subpages["pshy_checkpoints"] = pshy.help_pages["pshy_checkpoints"]



--- Internal use:
if not pshy.players then			-- adds checkpoint_x, checkpoint_y, checkpoint_hasCheese
	pshy.players = {}
end			
local just_dead_players = {}



--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
-- @param hasCheese Optional hasCheese tfm player property.
function pshy.checkpoints_SetPlayerCheckpoint(player_name, x, y, hasCheese)
	pshy.players[player_name] = pshy.players[player_name] or {}
	local player = pshy.players[player_name]
	x = x or tfm.get.room.playerList[player_name].x
	y = y or tfm.get.room.playerList[player_name].y
	hasCheese = hasCheese or tfm.get.room.playerList[player_name].hasCheese
	player.checkpoint_x = x
	player.checkpoint_y = y
	player.checkpoint_hasCheese = hasCheese
end



--- Set the checkpoint of a player.
-- @param player_name The player's name.
function pshy.checkpoints_UnsetPlayerCheckpoint(player_name)
	local player = pshy.players[player_name]
	player.checkpoint_x = nil
	player.checkpoint_y = nil
	player.checkpoint_hasCheese = nil
end



--- Teleport a player to its checkpoint.
-- Also gives him the cheese if he had it.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.checkpoints_PlayerCheckpoint(player_name)
	local player = pshy.players[player_name]
	if player.checkpoint_x then
		tfm.exec.respawnPlayer(player_name)
		tfm.exec.movePlayer(player_name, player.checkpoint_x, player.checkpoint_y, false, 0, 0, true)
		if player.checkpoint_hasCheese then
			tfm.exec.giveCheese(player_name)
		end
	end
end



--- TFM event eventPlayerWon.
-- temporary fix
function eventPlayerWon(player_name)
	tfm.get.room.playerList[player_name].hasCheese = false
end



--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	just_dead_players[player_name] = true
end



--- TFM event eventLoop.
function eventLoop()
	for dead_player in pairs(just_dead_players) do
		if pshy.players[dead_player].checkpoint_x then
			tfm.exec.respawnPlayer(dead_player)
		end
		just_dead_players[dead_player] = false
	end
end



--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	just_dead_players[player_name] = false
	pshy.checkpoints_PlayerCheckpoint(player_name)
end



--- TFM event eventNewGame.
function eventNewGame(player_name)
	for player_name, player in pairs(pshy.players) do
		player.checkpoint_x = nil
		player.checkpoint_y = nil
		player.checkpoint_hasCheese = nil
	end
	just_dead_players = {}
end



--- !checkpoint
pshy.commands["gotocheckpoint"] = {func = pshy.checkpoints_PlayerCheckpoint, desc = "teleport to your checkpoint if you have one", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["gotocheckpoint"] = pshy.commands["gotocheckpoint"]
pshy.perms.cheats["!gotocheckpoint"] = true



--- !setcheckpoint
pshy.commands["setcheckpoint"] = {func = pshy.checkpoints_SetPlayerCheckpoint, desc = "set your checkpoint to the current location", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["setcheckpoint"] = pshy.commands["setcheckpoint"]
pshy.perms.cheats["!setcheckpoint"] = true



--- !setcheckpoint
pshy.commands["unsetcheckpoint"] = {func = pshy.checkpoints_UnsetPlayerCheckpoint, desc = "delete your checkpoint", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["unsetcheckpoint"] = pshy.commands["unsetcheckpoint"]
pshy.perms.cheats["!unsetcheckpoint"] = true
