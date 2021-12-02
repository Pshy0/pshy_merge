--- pshy_keycodes.lua
--
-- This file is a memo for key codes.
-- This contains two maps:
--	- pshy.keycodes: map of key names to key codes
--	- pshy.keynames: map of key codes to key names
--
-- @author TFM:Pshy#3753 DC:Pshy#7998
-- @hardmerge
-- source: https://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
pshy = pshy or {}



--- Map of key name -> key code
pshy.keycodes = {}
-- Directions:
pshy.keycodes.LEFT = 0
pshy.keycodes.UP = 1
pshy.keycodes.RIGHT = 2
pshy.keycodes.DOWN = 3
-- modifiers
pshy.keycodes.SHIFT = 16
pshy.keycodes.CTRL = 17
pshy.keycodes.ALT = 18
-- Arrows:
pshy.keycodes.ARROW_LEFT = 37
pshy.keycodes.ARROW_UP = 38
pshy.keycodes.ARROW_RIGHT = 39
pshy.keycodes.ARROW_DOWN = 40
-- Letters
for i_letter = 0, 25 do
	pshy.keycodes[string.char(65 + i_letter)] = 65 + i_letter
end
-- Numbers (48 - 57):
for number = 0, 9 do
	pshy.keycodes["NUMBER_" .. tostring(number)] = 48 + number
end
-- Numpad Numbers (96 - 105):
for number = 0, 9 do
	pshy.keycodes["NUMPAD_" .. tostring(number)] = 96 + number
end
-- Numpad
pshy.keycodes.NUMPAD_MULTIPLY = 106
pshy.keycodes.NUMPAD_ADD = 107
pshy.keycodes.NUMPAD_SUBTRACT = 109
pshy.keycodes.NUMPAD_ENTER = 108
pshy.keycodes.NUMPAD_DECIMAL = 110
pshy.keycodes.NUMPAD_DIVIDE = 111
-- F1 - F12 (112 - 123)
for f_index = 0, 11 do
	pshy.keycodes["F" .. tostring(f_index + 1)] = 112 + f_index
end
-- Other
pshy.keycodes.BACKSPACE = 8
pshy.keycodes.TAB = 9
pshy.keycodes.ENTER = 13
pshy.keycodes.PAUSE = 19
pshy.keycodes.CAPSLOCK = 20
pshy.keycodes.ESCAPE = 27
pshy.keycodes.SPACE = 32
pshy.keycodes.PAGE_UP = 33
pshy.keycodes.PAGE_DOWN = 34
pshy.keycodes.END = 35
pshy.keycodes.HOME = 36
pshy.keycodes.INSERT = 45
pshy.keycodes.DELETE = 46
pshy.keycodes.SEMICOLON = 186
pshy.keycodes.EQUALS = 187
pshy.keycodes.COMMA = 188
pshy.keycodes.HYPHEN = 189
pshy.keycodes.PERIOD = 190
pshy.keycodes.SLASH = 191
pshy.keycodes.GRAVE = 192
pshy.keycodes.LEFTBRACKET = 219
pshy.keycodes.BACKSLASH = 220
pshy.keycodes.RIGHTBRACKET = 221



--- Map of key code -> key name
pshy.keynames = {}
for keyname, keycode in pairs(pshy.keycodes) do
	pshy.keynames[keycode] = keyname
end 
