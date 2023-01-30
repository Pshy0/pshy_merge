--- pshy.bases.splashscreen
--
-- Adds a splashscreen to a module that is displayed on startup or when a player join.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



--- Namespace.
local splashscreen = {}



--- Module Settings:
splashscreen.image = "17ab692dc8e.png"		-- splash image
splashscreen.x = 100						-- x location
splashscreen.y = -10						-- y location
splashscreen.sx = 1							-- scale on x
splashscreen.sy = 1							-- scale on y
splashscreen.text = "<fc>Pshy Module</fc>"	-- @todo splash text (over the image)
splashscreen.text_x = 0						-- x location of the text
splashscreen.text_y = 0						-- y location of the text
splashscreen.text_w = nil					-- width of the text, nil for auto
splashscreen.text_h = nil					-- height of the text, nil for auto
splashscreen.text_arbitrary_id = 13
splashscreen.text_backcolor = 0x0			-- back color of the text area
splashscreen.text_bordercolor = 0x0			-- border color of the text area
splashscreen.text_alpha = 1.0				-- opacity of the text
splashscreen.duration = 6 * 1000			-- duration of the splashscreen in milliseconds



--- Internal Use
local first_new_game = true



--- Called by timers when the splashscreen have to be deleted.
local function removeSplashImageCallback(callback_id, image_id)
	tfm.exec.removeImage(image_id, true)
end



--- Show the splashscreen to a player.
-- This is called automatically when a player join or the game start.
local function Show(player_name)
	local splash_image_id = tfm.exec.addImage(splashscreen.image, "&0", splashscreen.x, splashscreen.y, player_name, splashscreen.sx, splashscreen.sy)
	system.newTimer(removeSplashImageCallback, splashscreen.duration, false, splash_image_id)
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



return splashscreen
