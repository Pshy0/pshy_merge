--- pshy.bases.checkpoints
--
-- Adds respawn features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Namespace.
local checkpoints = {}



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Checkpoints", text = nil, details = "Use `<ch>!setperm everyone !setcheckpoint yes</ch>` to enable checkpoints for all players.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Internal use:
local player_checkpoints = {}
checkpoints.player_checkpoints = player_checkpoints
local just_dead_players = {}



--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
-- @param hasCheese Optional hasCheese tfm player property.
function checkpoints.SetPlayerCheckpoint(player_name, x, y, hasCheese)
	player_checkpoints[player_name] = player_checkpoints[player_name] or {}
	local player = player_checkpoints[player_name]
	x = x or tfm.get.room.playerList[player_name].x
	y = y or tfm.get.room.playerList[player_name].y
	hasCheese = hasCheese or tfm.get.room.playerList[player_name].hasCheese
	player.checkpoint_x = x
	player.checkpoint_y = y
	player.checkpoint_hasCheese = hasCheese
end



--- Set the checkpoint of a player.
-- @param player_name The player's name.
function checkpoints.UnsetPlayerCheckpoint(player_name)
	local player = player_checkpoints[player_name]
	player.checkpoint_x = nil
	player.checkpoint_y = nil
	player.checkpoint_hasCheese = nil
end



--- Teleport a player to its checkpoint.
-- Also gives him the cheese if he had it.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function checkpoints.PlayerCheckpoint(player_name)
	local player = player_checkpoints[player_name]
	if player and player.checkpoint_x then
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
		if player_checkpoints[dead_player] and player_checkpoints[dead_player].checkpoint_x then
			tfm.exec.respawnPlayer(dead_player)
		end
		just_dead_players[dead_player] = false
	end
end



--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	just_dead_players[player_name] = false
	checkpoints.PlayerCheckpoint(player_name)
end



--- TFM event eventNewGame.
function eventNewGame(player_name)
	for player_name, player in pairs(player_checkpoints) do
		player.checkpoint_x = nil
		player.checkpoint_y = nil
		player.checkpoint_hasCheese = nil
	end
	just_dead_players = {}
end



__MODULE__.commands = {
	["gotocheckpoint"] = {
		perms = "cheats",
		desc = "teleport to your checkpoint if you have one",
		argc_min = 0,
		argc_max = 0,
		arg_types = {},
		func = checkpoints.PlayerCheckpoint
	},
	["setcheckpoint"] = {
		perms = "cheats",
		desc = "set your checkpoint to the current location",
		argc_min = 0,
		argc_max = 0,
		arg_types = {},
		func = checkpoints.SetPlayerCheckpoint
	},
	["unsetcheckpoint"] = {
		perms = "cheats",
		desc = "delete your checkpoint",
		argc_min = 0,
		argc_max = 0,
		arg_types = {},
		func = checkpoints.UnsetPlayerCheckpoint
	}
}



return checkpoints
