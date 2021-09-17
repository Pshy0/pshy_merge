--- pshy_checkpoints.lua
--
-- Adds respawn features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua



--- Module Help Page:
pshy.help_pages["pshy_checkpoints"] = {back = "pshy", title = "Checkpoints", text = nil, commands = {}}
pshy.help_pages["pshy"].subpages["pshy_checkpoints"] = pshy.help_pages["pshy_checkpoints"]



--- Module Settings:
pshy.checkpoints_reset_on_new_game = true



--- Internal use:
pshy.checkpoints_player_locations = {}		-- x, y, hasCheese



--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.checkpoints_SetPlayerCheckpoint(player_name, x, y, hasCheese)
	pshy.checkpoints_player_locations[player_name] = {}
	x = x or tfm.get.room.playerList[player_name].x
	y = y or tfm.get.room.playerList[player_name].y
	hasCheese = hasCheese or tfm.get.room.playerList[player_name].hasCheese
	pshy.checkpoints_player_locations[player_name].x = x
	pshy.checkpoints_player_locations[player_name].y = y
	pshy.checkpoints_player_locations[player_name].hasCheese = hasCheese
end



--- Set the checkpoint of a player.
-- @param player_name The player's name.
function pshy.checkpoints_UnsetPlayerCheckpoint(player_name)
	pshy.checkpoints_player_locations[player_name] = nil
end



--- Teleport a player to its checkpoint.
-- Also gives him the cheese if he had it.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.checkpoints_PlayerCheckpoint(player_name)
	local checkpoint = pshy.checkpoints_player_locations[player_name]
	if checkpoint then
		tfm.exec.respawnPlayer(player_name)
		tfm.exec.movePlayer(player_name, checkpoint.x, checkpoint.y, false, 0, 0, true)
		if checkpoint.hasCheese then
			tfm.exec.giveCheese(player_name)
		end
	end
end



--- !checkpoint
pshy.chat_commands["checkpoint"] = {func = pshy.checkpoints_PlayerCheckpoint, desc = "teleport to your checkpoint if you have one", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["checkpoint"] = pshy.chat_commands["checkpoint"]
pshy.perms.cheats["!checkpoint"] = true



--- !setcheckpoint
pshy.chat_commands["setcheckpoint"] = {func = pshy.checkpoints_SetPlayerCheckpoint, desc = "set your checkpoint to the current location", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["setcheckpoint"] = pshy.chat_commands["setcheckpoint"]
pshy.perms.cheats["!setcheckpoint"] = true



--- !setcheckpoint
pshy.chat_commands["unsetcheckpoint"] = {func = pshy.checkpoints_UnsetPlayerCheckpoint, desc = "delete your checkpoint", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["unsetcheckpoint"] = pshy.chat_commands["unsetcheckpoint"]
pshy.perms.cheats["!unsetcheckpoint"] = true



--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	if pshy.checkpoints_player_locations[player_name] then
		tfm.exec.respawnPlayer(player_name)
	end
end



--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	pshy.checkpoints_PlayerCheckpoint(player_name)
end



--- TFM event eventNewGame
function eventNewGame(player_name)
	if pshy.checkpoints_reset_on_new_game then
		pshy.checkpoints_player_locations = {}
	end
end
