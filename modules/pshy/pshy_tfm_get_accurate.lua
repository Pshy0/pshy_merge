--- pshy_tfm_get_accurate.lua
--
-- This module update some fields events to make players fields in tfm.get more up to date.
--	tfm.get.room.playerList[?].hasCheese
--	tfm.get.room.playerList[?].x
--	tfm.get.room.playerList[?].y
--	tfm.get.room.playerList[?].isFacingRight
--
-- /!\ This module is experimental.
-- /!\ This may increase the time spent in the script consistently for big rooms.
-- Modules are stopped if the spent time is too high.
-- Also this may cause weird issues, for instance when creating the player tables with not all the fields.
-- The use of every implemented event is described above it, so you can choose what you need.
-- You may think about commenting out what you do not need.
-- /!\ For performance reasons, some of the events may be commented out in the release.
-- You can uncomment those if you wish.
--
-- @author pshy
-- @namespace pshy



--- Keys to listen
pshy.tfm_get_accurate_keys = {}
table.insert(pshy.tfm_get_accurate_keys, 0) -- up
table.insert(pshy.tfm_get_accurate_keys, 1) -- left
table.insert(pshy.tfm_get_accurate_keys, 2) -- right
table.insert(pshy.tfm_get_accurate_keys, 3) -- down



--- TFM event eventPlayergetCheese
-- Update the player's hasCheese and cheeses (limited) fields.
function eventPlayergetCheese(player_name)
	tfm.get.room.playerList[player_name].hasCheese = true
	tfm.get.room.playerList[player_name].cheeses = (tfm.get.room.playerList[player_name].cheeses > 0) or 1
end



--- TFM event eventPlayerDied
-- Update the player's isDead field.
function eventPlayerDied(player_name)
	--tfm.get.room.playerList[player_name] = tfm.get.room.playerList[player_name] or {} 
	tfm.get.room.playerList[player_name].isDead = true
end



--- TFM event eventPlayerMeep
-- Update the player's location.
function eventPlayerMeep(player_name, x, y)
	--tfm.get.room.playerList[player_name] = tfm.get.room.playerList[player_name] or {} 
	tfm.get.room.playerList[player_name].x = x
	tfm.get.room.playerList[player_name].y = y
end



--- TFM event
-- Update the player's location.
-- Update the player's direction.
function eventKeyboard(player_name, key_code, down, x, y)
	--tfm.get.room.playerList[player_name] = tfm.get.room.playerList[player_name] or {} 
	tfm.get.room.playerList[player_name].x = x
	tfm.get.room.playerList[player_name].y = y
	if key_code == 2 then
		tfm.get.room.playerList[player_name].isFacingRight = true
	elseif key_code == 0 then
		tfm.get.room.playerList[player_name].isFacingRight = false
	end
end



--- TFM event
-- Create the player table if he just joined.
-- Listen for the player keys (Required for keys events).
function eventNewPlayer(player_name)
	tfm.get.room.playerList[player_name] = tfm.get.room.playerList[player_name] or {} 
	for i_key, key in ipairs(pshy.tfm_get_accurate_keys) do
		tfm.exec.bindKeyboard(player_name, key, true, true)
		tfm.exec.bindKeyboard(player_name, key, false, true)
	end
end



--- Initialization
-- Listen for the player keys (Required for keys events).
for player_name in pairs(tfm.get.room.playerList) do
	for i_key, key in ipairs(pshy.tfm_get_accurate_keys) do
		tfm.exec.bindKeyboard(player_name, key, true, true)
		tfm.exec.bindKeyboard(player_name, key, false, true)
	end
end
