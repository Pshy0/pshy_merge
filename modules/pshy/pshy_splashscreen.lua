--- pshy_splashscreen.lua
--
-- Adds a splashscreen to a module that is displayed on startup or when a player join.
--
-- @todo: Use timers?
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_merge.lua



--- Module Settings:
pshy.splashscreen_image = "17ab692dc8e.png"		-- splash image
pshy.splashscreen_x = 0							-- x location
pshy.splashscreen_y = -10						-- y location
pshy.splashscreen_sx = 1						-- scale on x
pshy.splashscreen_sy = 1						-- scale on y
pshy.splashscreen_text = "<fc>Pshy Module</fc>"	-- @todo splash text (over the image)
pshy.splashscreen_text_x = 0					-- x location of the text
pshy.splashscreen_text_y = 0					-- y location of the text
pshy.splashscreen_text_w = nil					-- width of the text, nil for auto
pshy.splashscreen_text_h = nil					-- height of the text, nil for auto
pshy.splashscreen_text_arbitrary_id = 13
pshy.splashscreen_text_backcolor = 0x0			-- back color of the text area
pshy.splashscreen_text_bordercolor = 0x0		-- border color of the text area
pshy.splashscreen_text_alpha = 1.0				-- opacity of the text
pshy.splashscreen_duration = 10000				-- duration of the splashscreen in milliseconds



--- Internal Use
pshy.splashscreen_players_ids = {}
pshy.splashscreen_players_end_times = {}
pshy.splashscreen_last_loop_time = -1



--- Hide the splashscreen from a player.
-- This is called automatically after `pshy.splashscreen_duration` milliseconds.
function pshy.splashscreen_Hide(player_name)
	if pshy.splashscreen_players_ids[player_name] then
		tfm.exec.removeImage(pshy.splashscreen_players_ids[player_name])
		pshy.splashscreen_players_ids[player_name] = nil
	end
	ui.removeTextArea(pshy.splashscreen_text_arbitrary_id, player_name)
	pshy.splashscreen_players_end_times[player_name] = nil
end



--- Show the splashscreen to a player.
-- This is called automatically when a player join or the game start.
function pshy.splashscreen_Show(player_name)
	pshy.splashscreen_players_end_times[player_name] = pshy.splashscreen_last_loop_time + pshy.splashscreen_duration
	if pshy.splashscreen_image then
		pshy.splashscreen_players_ids[player_name] = tfm.exec.addImage(pshy.splashscreen_image, "&0", pshy.splashscreen_x, pshy.splashscreen_y, player_name, pshy.splashscreen_sx, pshy.splashscreen_sy)
	end
	if pshy.splashscreen_text then
		ui.addtextArea(pshy.splashscreen_text_arbitrary_id, pshy.splashscreen_text, player_name, pshy.splashscreen_text_x, pshy.splashscreen_text_y, pshy.splashscreen_text_w, pshy.splashscreen_text_h, pshy.splashscreen_text_backcolor, pshy.splashscreen_bordercolor, pshy.splashscreen_alpha, false)
	end
end



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.splashscreen_Show(player_name)
end



--- TFM event eventPlayerLeft
function eventPlayerLeft(player_name)
	pshy.splashscreen_Hide(player_name)
end



--- TFM event eventNewGame
-- Remove splashscreens on new games.
-- @todo Check if the game does automatically remove images already between games?
function eventNewGame()
	if pshy.splashscreen_last_loop_time > 0 then
		local timeouted = {}
		for player_name in pairs(pshy.splashscreen_players_end_times) do
			timeouted[player_name] = true
		end
		for player_name in pairs(timeouted) do
			pshy.splashscreen_Hide(player_name)
		end
		pshy.splashscreen_last_loop_time = 0
	end
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	-- remove timeouted splashscreens
	local timeouted = {}
	for player_name in pairs(pshy.splashscreen_players_end_times) do
		if pshy.splashscreen_players_end_times[player_name] < time then
			timeouted[player_name] = true
		end
	end
	for player_name in pairs(timeouted) do
		pshy.splashscreen_Hide(player_name)
	end
	-- first splash
	if pshy.splashscreen_last_loop_time < 0 then
		pshy.splashscreen_last_loop_time = time
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.splashscreen_Show(player_name)
		end
	end
	-- update last time
	pshy.splashscreen_last_loop_time = time
end
