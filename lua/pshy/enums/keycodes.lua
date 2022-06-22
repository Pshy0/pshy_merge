--- pshy.enums.keycodes
--
-- This file is a memo for key codes.
-- This contains two maps:
--	- keycodes: map of key names to key codes
--	- pshy.keynames: map of key codes to key names
--
-- @source https://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
-- @author TFM:Pshy#3753 DC:Pshy#7998



--- Map of key name -> key code
local keycodes = {}
-- Directions:
keycodes.LEFT = 0
keycodes.UP = 1
keycodes.RIGHT = 2
keycodes.DOWN = 3
-- modifiers
keycodes.SHIFT = 16
keycodes.CTRL = 17
keycodes.ALT = 18
-- Arrows:
keycodes.ARROW_LEFT = 37
keycodes.ARROW_UP = 38
keycodes.ARROW_RIGHT = 39
keycodes.ARROW_DOWN = 40
-- Letters
for i_letter = 0, 25 do
	keycodes[string.char(65 + i_letter)] = 65 + i_letter
end
-- Numbers (48 - 57):
for number = 0, 9 do
	keycodes["NUMBER_" .. tostring(number)] = 48 + number
end
-- Numpad Numbers (96 - 105):
for number = 0, 9 do
	keycodes["NUMPAD_" .. tostring(number)] = 96 + number
end
-- Numpad
keycodes.NUMPAD_MULTIPLY = 106
keycodes.NUMPAD_ADD = 107
keycodes.NUMPAD_SUBTRACT = 109
keycodes.NUMPAD_ENTER = 108
keycodes.NUMPAD_DECIMAL = 110
keycodes.NUMPAD_DIVIDE = 111
-- F1 - F12 (112 - 123)
for f_index = 0, 11 do
	keycodes["F" .. tostring(f_index + 1)] = 112 + f_index
end
-- Other
keycodes.BACKSPACE = 8
keycodes.TAB = 9
keycodes.ENTER = 13
keycodes.PAUSE = 19
keycodes.CAPSLOCK = 20
keycodes.ESCAPE = 27
keycodes.SPACE = 32
keycodes.PAGE_UP = 33
keycodes.PAGE_DOWN = 34
keycodes.END = 35
keycodes.HOME = 36
keycodes.INSERT = 45
keycodes.DELETE = 46
keycodes.SEMICOLON = 186
keycodes.EQUALS = 187
keycodes.COMMA = 188
keycodes.HYPHEN = 189
keycodes.PERIOD = 190
keycodes.SLASH = 191
keycodes.GRAVE = 192
keycodes.LEFTBRACKET = 219
keycodes.BACKSLASH = 220
keycodes.RIGHTBRACKET = 221



return keycodes
