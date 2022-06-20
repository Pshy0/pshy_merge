--- pshy.enums.keycodes
--
-- This file is a memo for key codes.
-- This contains two maps:
--	- pshy.keycodes: map of key names to key codes
--	- pshy.keynames: map of key codes to key names
--
-- @source: https://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
-- @author TFM:Pshy#3753 DC:Pshy#7998
--
-- @hardmerge
local keycodes = pshy.require("pshy.enums.keycodes")



--- Map of key code -> key name
local keynames = {}
for keyname, keycode in pairs(pshy.keycodes) do
	pshy.keynames[keycode] = keyname
end



return keynames
