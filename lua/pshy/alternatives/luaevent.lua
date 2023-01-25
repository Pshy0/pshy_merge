--- pshy.alternatives.luaevent
--
-- Replaces some module-team-only functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local uniqueplayers = pshy.require("pshy.alternatives.uniqueplayers")
pshy.require("pshy.utils.print")



if not uniqueplayers.have_uniqueplayers_access then



	system.giveAdventurePoint = function(player_name, achievement, amount)
		if type(player_name) ~= "string" then
			return print_error("system.openEventShop: player_name must be a string")
		end
		if type(achievement) ~= "string" then
			return print_error("system.giveAdventurePoint: achievement must be a string")
		end
		amount = amount or 1
		tfm.exec.chatMessage(string.format("▣ <j>Adventure Points Received</j>: <vp>%s (%d)</vp>", achievement, amount), player_name)
	end



	system.giveEventGift = function(player_name, gift_code)
		if type(player_name) ~= "string" then
			return print_error("system.openEventShop: player_name must be a string")
		end
		tfm.exec.chatMessage(string.format("▣ <j>Event Gift received</j>: <vp>%s</vp>", gift_code), nil --[[player_name]])
	end



	system.luaEventLaunchInterval = function(interval, random)
		interval = interval or 40
		random = random or 20
		tfm.exec.chatMessage(string.format("▣ <j>Lua Event would play every <vp>%d minutes</vp> (<vp>+/- %d</vp>)</j>", interval, random))
	end



	system.openEventShop = function(event_name, player_name)
		if type(event_name) ~= "string" then
			return print_error("system.openEventShop: event_name must be a string")
		end
		if type(player_name) ~= "string" then
			return print_error("system.openEventShop: player_name must be a string")
		end
		tfm.exec.chatMessage(string.format("▣ <j>Opened Event Shop <vp>%s</vp>!</j>", event_name), nil --[[player_name]])
	end



	system.setLuaEventBanner = function(banner_id)
		if type(banner_id) ~= "number" then
			return print_error("system.setLuaEventBanner: banner_id must be a number")
		end
		tfm.exec.chatMessage(string.format("▣ <j>Lua Event banner set to <vp>%d</vp></j>", banner_id))
	end
	


end
