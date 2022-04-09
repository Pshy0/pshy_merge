--- pshy_players_alive.lua
--
-- Adds a table of alive players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_players.lua
pshy = pshy or {}



--- Alive players counter
pshy.players_alive = {}
pshy.players_alive_count = 0



--- Internal use:
local players = pshy.players
local players_in_room = pshy.players_in_room
local players_alive = pshy.players_alive



function eventNewGame()
	for player_name, players in pairs(players_in_room) do
		players_alive[player_name] = player
	end
	pshy.players_alive_count = pshy.players_in_room_count
end



function eventPlayerDied(player_name)
	if players_alive[player_name] then
		players_alive[player_name] = nil
		pshy.players_alive_count = pshy.players_alive_count - 1
	end
end



function eventPlayerWon(player_name)
	if players_alive[player_name] then
		players_alive[player_name] = nil
		pshy.players_alive_count = pshy.players_alive_count - 1
	end
end



function eventPlayerRespawn(player_name)
	if not players_alive[player_name] then
		players_alive[player_name] = players[player_name]
		pshy.players_alive_count = pshy.players_alive_count + 1
	end
end



--- Init:
-- Not using eventInit in order to make some features available early.
pshy.players_alive_count = 0
for player_name, player in pairs(tfm.get.room.playerList) do
	if not player.isDead then
		pshy.players_alive_count = pshy.players_alive_count + 1
	end
end
