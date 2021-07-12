--- pshy_emoticons.lua
--
-- Adds emoticons you can use with SHIFT and ALT.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- LUA constants
local LUA_KEY_SHIFT = 16
local LUA_KEY_ALT = 18
local LUA_KEY_NUMBER_0 = 48
local LUA_KEY_R = 82



--- Module Help Page:
--- Module Help Page:
pshy.help_pages["pshy_emoticons"] = {back = "pshy", title = "Emoticons", text = "Adds custom emoticons\nCombine CTRL, ALT and number keys to use them.\n", examples = {}, commands = {}}
pshy.help_pages["pshy"].subpages["pshy_emoticons"] = pshy.help_pages["pshy_emoticons"]



--- Module Settings:
pshy.emoticons = {}		-- emoticons / index is (key_number + (10 * alt) + (20 * shift)) for up to 40 emoticons, including the defaults
pshy.emoticons[10] = "16f56cbc4d7.png" -- https://atelier801.com/topic?f=6&t=894050&p=1#m16
pshy.emoticons[12] = "17088661168.png"
pshy.emoticons[13] = "16f5d8c7401.png"
pshy.emoticons[15] = "16f56ce925e.png"
pshy.emoticons[17] = "16f56cdf28f.png"
pshy.emoticons[18] = "16f56d09dc2.png"
-- @todo 24 slots remaining :>



-- Internal Use:
pshy.emoticons_players_shift = {}				-- shift keys state
pshy.emoticons_players_alt = {}					-- alt keys state
pshy.emoticons_last_loop_time = 0				-- last loop time
pshy.emoticons_players_image_ids = {}			-- the emote id started by the player
pshy.emoticons_players_emoticons = {}			-- the name of the emoticon being used per player
pshy.emoticons_players_end_times = {}			-- time at wich players started an emote / NOT DELETED



--- Listen for a players modifiers:
function pshy.EmoticonsBindPlayerKeys(player_name)
	system.bindKeyboard(player_name, LUA_KEY_SHIFT, true, true)
	system.bindKeyboard(player_name, LUA_KEY_SHIFT, false, true)
	system.bindKeyboard(player_name, LUA_KEY_ALT, true, true)
	system.bindKeyboard(player_name, LUA_KEY_ALT, false, true)
	for number = 0, 9 do
		system.bindKeyboard(player_name, LUA_KEY_NUMBER_0 + number, true, true)
	end
end



--- Stop an imoticon from playing over a player.
function pshy.EmoticonsStop(player_name)
	tfm.exec.removeImage(pshy.emoticons_players_image_ids[player_name])
	pshy.emoticons_players_end_times[player_name] = nil
	pshy.emoticons_players_image_ids[player_name] = nil
	pshy.emoticons_players_emoticons[player_name] = nil
end



--- Play an emoticon over a player.
-- Also removes the current one if being played.
function pshy.EmoticonsPlay(player_name, image_name, end_time)
	if pshy.emoticons_players_emoticons[player_name] ~= image_name then
		if pshy.emoticons_players_image_ids[player_name] then
			tfm.exec.removeImage(pshy.emoticons_players_image_ids[player_name])
		end
		pshy.emoticons_players_image_ids[player_name] = tfm.exec.addImage(image_name, "$" .. player_name, 0 - 15, -60, nil)
	pshy.emoticons_players_emoticons[player_name] = image_name
	end
	pshy.emoticons_players_end_times[player_name] = end_time
end



--- TFM event eventNewGame
function eventNewGame()
	local timeouts = {}
	for player_name, end_time in pairs(pshy.emoticons_players_end_times) do
		timeouts[player_name] = true
	end
	for player_name in pairs(timeouts) do
		pshy.EmoticonsStop(player_name)
	end
	pshy.emoticons_last_loop_time = 0
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	local timeouts = {}
	for player_name, end_time in pairs(pshy.emoticons_players_end_times) do
		if end_time < time then
			timeouts[player_name] = true
		end
	end
	for player_name in pairs(timeouts) do
		pshy.EmoticonsStop(player_name)
	end
	pshy.emoticons_last_loop_time = time
end



--- TFM event eventKeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	if key_code == LUA_KEY_SHIFT then
		pshy.emoticons_players_shift[player_name] = down
	elseif key_code == LUA_KEY_ALT then
		pshy.emoticons_players_alt[player_name] = down
	elseif key_code >= LUA_KEY_NUMBER_0 and key_code < LUA_KEY_NUMBER_0 + 10 then
		local index = (key_code - LUA_KEY_NUMBER_0) + (pshy.emoticons_players_alt[player_name] and 10 or 0) + (pshy.emoticons_players_shift[player_name] and 20 or 0)
		image_name = pshy.emoticons[index]
		pshy.emoticons_players_emoticons[player_name] = index -- todo sadly, native emoticons will always replace custom ones
		if image_name then
			pshy.EmoticonsPlay(player_name, image_name, pshy.emoticons_last_loop_time + 4500)
		else
			pshy.emoticons_players_emoticons[player_name] = index
		end
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.EmoticonsBindPlayerKeys(player_name)
end



--- Initialization:
for player_name in pairs(tfm.get.room.playerList) do
	pshy.EmoticonsBindPlayerKeys(player_name)
end
