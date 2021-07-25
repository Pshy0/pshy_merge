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
pshy.checkpoints_player_locations = {}



--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.CheckpointsSetPlayerCheckpoint(player_name, x, y)
	pshy.checkpoints_player_locations[player_name] = {}
	x = x or tfm.get.room.playerList[player_name].x
	y = y or tfm.get.room.playerList[player_name].y
	pshy.checkpoints_player_locations[player_name].x = x
	pshy.checkpoints_player_locations[player_name].y = y
end



--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.CheckpointsUnsetPlayerCheckpoint(player_name, x, y)
	pshy.checkpoints_player_locations[player_name] = nil
end



--- Teleport a player to its checkpoint.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.CheckpointsPlayerCheckpoint(player_name)
	local checkpoint = pshy.checkpoints_player_locations[player_name]
	if checkpoint then
		tfm.exec.respawnPlayer(player_name)
		tfm.exec.movePlayer(player_name, checkpoint.x, checkpoint.y, false, 0, 0, true)
	end
end



--- !checkpoint
pshy.chat_commands["checkpoint"] = {func = pshy.CheckpointsPlayerCheckpoint, desc = "teleport to your checkpoint if you have one", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["checkpoint"] = pshy.chat_commands["checkpoint"]
pshy.perms.everyone["!checkpointset"] = false



--- !setcheckpoint
pshy.chat_commands["setcheckpoint"] = {func = pshy.CheckpointsSetPlayerCheckpoint, desc = "set your checkpoint to the current location", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["setcheckpoint"] = pshy.chat_commands["setcheckpoint"]
pshy.perms.everyone["!checkpointset"] = false



--- !setcheckpoint
pshy.chat_commands["unsetcheckpoint"] = {func = pshy.CheckpointsUnsetPlayerCheckpoint, desc = "delete your checkpoint", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["unsetcheckpoint"] = pshy.chat_commands["unsetcheckpoint"]
pshy.perms.everyone["!unsetcheckpoint"] = false



--- TFM event eventPlayerDied
function eventPlayerRespawn(player_name)
	pshy.CheckpointsPlayerCheckpoint(player_name)
end



--- TFM event eventNewGame
function eventNewGame(player_name)
	if pshy.checkpoints_reset_on_new_game then
		pshy.checkpoints_player_locations = {}
	end
end
