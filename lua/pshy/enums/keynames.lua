--- pshy.enums.keycodes
--
-- @source: https://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
-- @author TFM:Pshy#3753 DC:Pshy#7998
local keycodes = pshy.require("pshy.enums.keycodes")



--- Map of key code -> key name
local keynames = {}
for keyname, keycode in pairs(keycodes) do
	keynames[keycode] = keyname
end



return keynames
