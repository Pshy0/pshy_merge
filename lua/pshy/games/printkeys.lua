--- pshy.games.printkeys
--
-- Script that binds all keys and print the name and code of the ones you press.
--
-- @author TFM:Pshy#3753 DC:Pshy#7998
pshy.require("pshy.events")
local keycodes = pshy.require("pshy.enums.keycodes")
local keynames = pshy.require("pshy.enums.keynames")
pshy.require("pshy.utils.print")
local room = pshy.require("pshy.room")



function BindKeys(player_name)
	for key_name, key_code in pairs(keycodes) do
		system.bindKeyboard(player_name, key_code, true, true)
	end
end



function eventNewPlayer(player_name)
	BindKeys(player_name)
end



function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		BindKeys(player_name)
	end
end



function eventKeyboard(player_name, keycode, down, x, y)
	text = string.format("KEY %s / %d", keynames[keycode] or "UNKNOWN", keycode)
	if not room.is_tribehouse then
		tfm.exec.chatMessage(text, player_name)
	end
	print_debug(string.format("[%s] %s", player_name, text))
end
