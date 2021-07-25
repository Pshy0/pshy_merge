--- pshy_accuracy.lua
--
-- This module gives better accuracy to the players fields in `tfm.get.room.playerList`,
-- by using events to update informations.
--
-- Fields subject to more frequent updates:
--	tfm.get.room.playerList[?].x
--	tfm.get.room.playerList[?].y
--	tfm.get.room.playerList[?].isFacingRight
--	tfm.get.room.playerList[?].hasCheese
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy



--- Module Settings:
pshy.accuracy_down_keys = {0, 1, 2, 3}			-- keys to listen to when pressed
pshy.accuracy_up_keys = {0, 1, 2, 3}			-- keys to listen to when released



--- Tells the module a player is in the room or just joined it.
-- @private
function pshy.accuracy_Touch(player_name)
	for i_key, key in ipairs(pshy.accuracy_down_keys) do
		tfm.exec.bindKeyboard(player_name, key, true, true)
	end
	for i_key, key in ipairs(pshy.accuracy_up_keys) do
		tfm.exec.bindKeyboard(player_name, key, false, true)
	end
end



-- Update the player's direction.
function eventKeyboard(player_name, key_code, down, x, y)
	-- update x and y
	tfm.get.room.playerList[player_name].x = x
	tfm.get.room.playerList[player_name].y = y
	-- update isFacingRight
	if key_code == 2 and down then
		tfm.get.room.playerList[player_name].isFacingRight = true
	elseif key_code == 0 and down then
		tfm.get.room.playerList[player_name].isFacingRight = false
	end
end



--- TFM event eventPlayerMeep
-- Update the player's location.
function eventPlayerMeep(player_name, x, y)
	-- update x and y
	tfm.get.room.playerList[player_name].x = x
	tfm.get.room.playerList[player_name].y = y
end



--- TFM event eventPlayerGetCheese
function eventPlayerGetCheese(player_name)
	-- update hasCheese
	tfm.get.room.playerList[player_name].hasCheese = true
end



--- TFM event eventPlayerDied
-- Update the player's isDead field.
function eventPlayerDied(player_name)
	-- update isDead
	tfm.get.room.playerList[player_name].isDead = true
end



--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	pshy.accuracy_Touch(player_name)
end



--- Initialization:
for player_name in pairs(tfm.get.room.playerList) do
	pshy.accuracy_Touch(player_name)
end
