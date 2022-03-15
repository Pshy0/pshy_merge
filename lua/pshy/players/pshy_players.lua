--- pshy_players.lua
--
-- A global `pshy.players` table to store players informations.
-- Other modules may add their fields to a player's table, using that module's prefix.
--
-- Player fields provided by this module:
--	- `name`:					The Name#0000 of the player.
--	- `tfm_player`:				The corresponding table entry in `tfm.get.room.playerList`.
--	- `tag`:					The # tag of the player or nil for guests.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_merge.lua
--
-- @require_priority UTILS
pshy = pshy or {}



--- Module settings and public members:
pshy.delete_players_on_leave = false			-- delete a player's table when they leave
if not pshy.players then
	pshy.players = {}
end



--- Ensure a table entry exist in `pshy.players` for a player, creating it if required.
-- Also set the default fields in the table.
-- @param player_name The Name#0000 if the player.
local function TouchPlayer(player_name)
	if pshy.players[player_name] then
		return
	end
	local new_player = {}
	new_player.name = player_name
	new_player.tfm_player = tfm.get.room.playerList[player_name]
	new_player.tag = string.match(player_name, "#....$")
	pshy.players[player_name] = new_player
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventPlayerLeft(player_name)
    if pshy.delete_players_on_leave then
    	pshy.players[player_name] = nil
    end
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end	
end
