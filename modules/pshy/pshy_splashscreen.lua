--- pshy_splashscreen.lua
--
-- Adds a splashscreen to a module that is displayed on startup or when a player join.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_merge.lua



--- Module Settings:
pshy.splashscreen_image = "17ab692dc8e.png"		-- splash image
pshy.splashscreen_text = "Pshy Module"			-- @todo splash text (over the image)
pshy.splashscreen_x = 0							-- x location
pshy.splashscreen_y = -10						-- y location
pshy.splashscreen_sx = 1						-- scale on x
pshy.splashscreen_sy = 1						-- scale on y
pshy.splashscreen_duration = 10000				-- duration of the splashscreen



--- Internal Use
pshy.splashscreen_players_ids = {}
pshy.splashscreen_players_end_times = {}
pshy.splashscreen_last_loop_time = -1



--- Show the splashscreen to a player.
function pshy.splashscreen_Show(player_name)
	pshy.splashscreen_players_ids[player_name] = tfm.exec.addImage(pshy.splashscreen_image, "&0", pshy.splashscreen_x, pshy.splashscreen_y, player_name, pshy.splashscreen_sx, pshy.splashscreen_sy)
	pshy.splashscreen_players_end_times[player_name] = pshy.splashscreen_last_loop_time + pshy.splashscreen_duration
end




--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.splashscreen_Show(player_name)
end



--- TFM event eventNewGame
function eventNewGame()
	for player_name, image_id in pairs(pshy.splashscreen_players_ids) do
		tfm.exec.removeImage(image_id)
	end 
	pshy.splashscreen_players_ids = {}
	pshy.splashscreen_players_end_times = {}
	if pshy.splashscreen_last_loop_time > 0 then
		pshy.splashscreen_last_loop_time = 0
	end
end



--- TFM event eventLoop
function eventLoop(time, time_remaining)
	-- remove timeouted splashscreens
	local timeouted = {}
	for player_name, image_id in pairs(pshy.splashscreen_players_ids) do
		if pshy.splashscreen_players_end_times[player_name] < time then
			tfm.exec.removeImage(image_id)
			timeouted[player_name] = true
		end
	end
	for player_name in pairs(timeouted) do
		pshy.splashscreen_players_ids[player_name] = nil
		pshy.splashscreen_players_end_times[player_name] = nil
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
