--- pshy.players
--
-- A global `pshy.players` table to store players informations.
-- Other modules may add their fields to a player's table, using that module's prefix.
--
-- Player fields provided by this module:
--	- `name`:					The Name#0000 of the player.
--	- `tfm_player`:				The corresponding table entry in `tfm.get.room.playerList` when the player joined (not updated).
--	- `tag`:					The # tag of the player or nil for guests.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



--- Module settings and public members:
pshy.delete_players_on_leave = false			-- delete a player's table when they leave
pshy.players = {}								-- all player data saved in the module
pshy.players_in_room = {}						-- only players in the room
pshy.players_in_room_count = 0					-- count players in the room



--- Internal Use:
local players = pshy.players
local players_in_room = pshy.players_in_room



--- Ensure a table entry exist in `pshy.players` for a player, creating it if required.
-- Also set the default fields in the table.
-- @param player_name The Name#0000 if the player.
local function TouchPlayer(player_name)
	if not players[player_name] then
		local new_player = {}
		new_player.name = player_name
		new_player.tfm_player = tfm.get.room.playerList[player_name]
		new_player.tag = string.match(player_name, "#....$")
		players[player_name] = new_player
		players_in_room[player_name] = new_player
	else
		players_in_room[player_name] = players[player_name]
	end
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
	pshy.players_in_room_count = pshy.players_in_room_count + 1
end



function eventPlayerLeft(player_name)
    players_in_room[player_name] = nil
    pshy.players_in_room_count = pshy.players_in_room_count - 1
end



--- Init:
-- Not using eventInit in order to make some features available early.
for player_name in pairs(tfm.get.room.playerList) do
	TouchPlayer(player_name)
	pshy.players_in_room_count = pshy.players_in_room_count + 1
end
