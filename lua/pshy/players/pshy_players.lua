--- pshy_players.lua
--
-- A global `pshy.players` table to store players informations.
-- Other modules may add their fields to a player's table, using that module's prefix.
--
-- Player fields provided by this module:
--	- `name`:					The Name#0000 of the player.
--	- `tfm_player`:				The corresponding table entry in `tfm.get.room.playerList`.
--	- `has_admin_tag`		
--	- `has_moderator_tag`		
--	- `has_sentinel_tag`		
--	- `has_mapcrew_tag`				
--	- `has_previous_staff_tag`		
--	- `alive`					`true` if the player is alive.
--	- `won`						`true` if the player has entered the hole.
--	- `cheeses`					How many cheeses this player have.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_merge.lua
--
-- @require_priority UTILS
pshy = pshy or {}



--- Module settings and public members:
pshy.delete_players_on_leave = false			-- delete a player's table when they leave
pshy.players = {}								-- the global players table



--- Ensure a table entry exist in `pshy.players` for a player, creating it if required.
-- Also set the default fields in the table.
-- @private
-- @param player_name The Name#0000 if the player.
function pshy.players_Touch(player_name)
	if pshy.players[player_name] then
		return
	end
	local new_player = {}
	new_player.name = player_name
	new_player.tfm_player = tfm.get.room.playerList[player_name]
	new_player.has_admin_tag = (string.sub(player_name, -5) == "#0001")
	new_player.has_moderator_tag = (string.sub(player_name, -5) == "#0010")
	new_player.has_sentinel_tag = (string.sub(player_name, -5) == "#0015")
	new_player.has_mapcrew_tag = (string.sub(player_name, -5) == "#0020")
	new_player.has_previous_staff_tag = (string.sub(player_name, -5) == "#0095")
	new_player.alive = false
	new_player.won = false
	new_player.cheeses = 0
	pshy.players[player_name] = new_player
end



function eventNewPlayer(player_name)
	pshy.players_Touch(player_name)
end



function eventPlayerLeft(player_name)
    if pshy.delete_players_on_leave then
    	pshy.players[player_name] = nil
    end
	local player = pshy.players[player_name]
	player.alive = false
	player.cheeses = 0
end



function eventNewGame()
	for player_name in pairs(tfm.get.room.playerList) do
		local player = pshy.players[player_name]
		player.alive = true
		player.won = false
		player.cheeses = 0
	end
end



function eventPlayerWon(player_name)
	local player = pshy.players[player_name]
	player.alive = false
	player.won = true
	player.cheeses = 0
end



function eventPlayerDied(player_name)
	pshy.players[player_name].alive = false
end



function eventPlayerGetCheese(player_name)
	local player = pshy.players[player_name]
	player.cheeses = player.cheeses + 1
end



function eventPlayerRespawn(player_name)
	local player = pshy.players[player_name]
	player.alive = true
	if player.won then
		player.won = false
		player.cheeses = 0
	end
end



--- tfm.exec.giveCheese hook.
-- @TODO: test on multicheese maps.
local tfm_giveCheese = tfm.exec.giveCheese
tfm.exec.giveCheese = function(player_name)
	if pshy.players[player_name] then
		pshy.players[player_name].cheeses = 1
	end
	return tfm_giveCheese(player_name)
end



--- tfm.exec.removeCheese hook.
local tfm_removeCheese = tfm.exec.removeCheese
tfm.exec.removeCheese = function(player_name)
	if pshy.players[player_name] then
		pshy.players[player_name].cheeses = 0
	end
	return tfm_removeCheese(player_name)
end



--- tfm.exec.respawnPlayer hook.
local tfm_respawnPlayer = tfm.exec.respawnPlayer
tfm.exec.respawnPlayer = function(player_name)
	if pshy.players[player_name] then
		pshy.players[player_name].cheeses = 0
	end
	return tfm_respawnPlayer(player_name)
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		pshy.players_Touch(player_name)
	end	
end
