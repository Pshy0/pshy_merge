--- pshy.players.is_facing_right
--
-- Extends `pshy.players` with a `is_facing_right` field.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.players")



--- Internal Use:
local players = pshy.players			-- optimization



--- Tell the script that a player exist.
local function TouchPlayer(player_name)
	players[player_name].is_facing_right = true
	system.bindKeyboard(player_name, 0, true, true)
	system.bindKeyboard(player_name, 2, true, true)
end



function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end



function eventNewGame()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end



function eventPlayerRespawn(player_name)
	players[player_name].is_facing_right = true
end



function eventKeyboard(player_name, keycode, down)
	if down then
		if keycode == 0 then
			players[player_name].is_facing_right = false
		elseif keycode == 2 then
			players[player_name].is_facing_right = true
		end
	end
end
