--- pshy_players.lua
--
-- A global `pshy.players` table to store players informations.
-- Other modules may add their fields to a player's table, using that module's prefix.
--
-- Player fields provided by this module:
--	- `name`: The Name#0000 of the player.
--	- `tfm_player`: The corresponding table entry in `tfm.get.room.playerList`.
--
-- Usage of this module by other `pshy` have been dropped, but it may be reimplemented in the future.
-- The advantages of using it are to be evaluated.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
pshy = pshy or {}



--- Module settings and public members:
pshy.delete_players_on_leave = false			-- delete a player's table when they leave
pshy.players = {}								-- the global players table



--- Ensure a table entry exist in `pshy.players` for a player, creating it if required.
-- Default fields `name` and `tfm_player` are also defined.
-- @private
-- @param player_name The Name#0000 if the player.
function pshy.players_Touch(player_name)
	pshy.players[player_name] = pshy.players[player_name] or {}
	pshy.players[player_name].name = player_name
	pshy.players[player_name].tfm_player = tfm.get.room.playerList[player_name]
end



--- Reset the `pshy.players` tables, adding entries in it for players who are already in the room.
-- @private
function pshy.players_Reset()
	pshy.players = {}
	for player_name in pairs(tfm.get.room.playerList) do
		pshy.players_Touch(player_name)
	end
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	pshy.players_Touch(player_name)
end



--- TFM event eventPlayerLeft.
function eventPlayerLeft(player_name)
    if pshy.delete_players_on_leave then
    	pshy.players[player_name] = nil
    end
end



--- Initialization
pshy.players_Reset()
