--- pshy.players.alive
--
-- Adds a table of alive players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.players")



--- Alive players counter
players.alive = {}
players.alive_count = 0



--- Internal use:
local players = players.list
local players_in_room = players.in_room
local players_alive = players.alive



function eventNewGame()
	for player_name, player in pairs(players_in_room) do
		players_alive[player_name] = player
	end
	players.alive_count = players.in_room_count
end



function eventPlayerDied(player_name)
	if players_alive[player_name] then
		players_alive[player_name] = nil
		players.alive_count = players.alive_count - 1
	end
end



function eventPlayerWon(player_name)
	if players_alive[player_name] then
		players_alive[player_name] = nil
		players.alive_count = players.alive_count - 1
	end
end



function eventPlayerRespawn(player_name)
	if not players_alive[player_name] then
		players_alive[player_name] = players[player_name]
		players.alive_count = players.alive_count + 1
	end
end



--- Init:
-- Not using eventInit in order to make some features available early.
players.alive_count = 0
for player_name, player in pairs(tfm.get.room.playerList) do
	if not player.isDead then
		players.alive_count = players.alive_count + 1
	end
end
