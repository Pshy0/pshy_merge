--- pshy.bases.splashscreen
--
-- Adds a splashscreen to a module that is displayed on startup or when a player join.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.events")



--- Module Settings:
pshy.splashscreen_image = "17ab692dc8e.png"		-- splash image
pshy.splashscreen_x = 100						-- x location
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
pshy.splashscreen_duration = 6 * 1000			-- duration of the splashscreen in milliseconds



--- Internal Use
local first_new_game = true



--- Called by timers when the splashscreen have to be deleted.
local function removeSplashImageCallback(callback_id, image_id)
	tfm.exec.removeImage(image_id)
end



--- Show the splashscreen to a player.
-- This is called automatically when a player join or the game start.
local function Show(player_name)
	local splash_image_id = tfm.exec.addImage(pshy.splashscreen_image, "&0", pshy.splashscreen_x, pshy.splashscreen_y, player_name, pshy.splashscreen_sx, pshy.splashscreen_sy)
	system.newTimer(removeSplashImageCallback, pshy.splashscreen_duration, false, splash_image_id)
end



--- Called by a timer 1 second after the script loaded, in case there were no new game.
local function showSplashIfNoNewgameCallback()
	if first_new_game then
		Show(nil)
		first_new_game = false
	end
end



function eventNewGame()
	if first_new_game then
		Show(nil)
		first_new_game = false
	end
end



function eventNewPlayer(player_name)
	if not first_new_game then
		Show(player_name)
	end
end



function eventInit()
	system.newTimer(showSplashIfNoNewgameCallback, 1000, false)
end
