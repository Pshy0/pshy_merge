--- pshy.enums.keycodes
--
-- Map of key names to key codes.
--
-- @source https://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
-- @author TFM:Pshy#3753 DC:Pshy#7998



--- Map of key name -> key code:
local keycodes = {
	-- directions (all keys)
	LEFT = 0;
	UP = 1;
	RIGHT = 2;
	DOWN = 3;
	-- modifiers
	SHIFT = 16;
	CTRL = 17;
	ALT = 18;
	-- arrows
	ARROW_LEFT = 37;
	ARROW_UP = 38;
	ARROW_RIGHT = 39;
	ARROW_DOWN = 40;
	-- Numpad
	NUMPAD_MULTIPLY = 106;
	NUMPAD_ADD = 107;
	NUMPAD_SUBTRACT = 109;
	NUMPAD_ENTER = 108;
	NUMPAD_DECIMAL = 110;
	NUMPAD_DIVIDE = 111;
	-- Other
	BACKSPACE = 8;
	TAB = 9;
	ENTER = 13;
	PAUSE = 19;
	CAPSLOCK = 20;
	ESCAPE = 27;
	SPACE = 32;
	PAGE_UP = 33;
	PAGE_DOWN = 34;
	END = 35;
	HOME = 36;
	INSERT = 45;
	DELETE = 46;
	SEMICOLON = 186;
	EQUALS = 187;
	COMMA = 188;
	HYPHEN = 189;
	PERIOD = 190;
	SLASH = 191;
	GRAVE = 192;
	LEFTBRACKET = 219;
	BACKSLASH = 220;
	RIGHTBRACKET = 221;
}



-- F1 - F12 (112 - 123)
for f_index = 0, 11 do
	keycodes["F" .. tostring(f_index + 1)] = 112 + f_index
end
-- letters
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



return keycodes
