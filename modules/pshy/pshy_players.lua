--- pshy_players.lua
--
-- This module serve as a base for pshy modules.
-- It probably should be the first module required.
--
-- This creates an entry in the pshy.players map per player.
--
-- @author pshy
pshy = pshy or {}



--- Module settings:
pshy.delete_players_on_leave = false		-- Delete player data when they leave



--- Players map (key is the player name).
-- Fields:
--	name			- name of the player
--	score			- score variable, set to 0 on join
-- Fields from other modules (optional):
--	team_name
pshy.players = {}



--- Reload players.
-- Should probably be used when restarting the module.
function pshy.ReloadPlayers()
	pshy.players = {}
	for player_name, player in tfm.get.room.playerList do
		local new_player = {}
		new_player.name = playerName
		new_player.score = 0
		pshy.players[playerName] = new_player
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(playerName)
	if not pshy.players[playerName] then
		local new_player = {}
		new_player.name = playerName
		new_player.score = 0
		pshy.players[playerName] = new_player
	end
end



--- TFM event eventPlayerLeft
function eventPlayerLeft(playerName)
    if pshy.delete_players_on_leave then
    	pshy.players[playerName] = nil
    end
end



--- Initialization
pshy.ReloadPlayers()
