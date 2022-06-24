--- pshy.tfm_emulator.controls
--
-- Simulate keyboard & mouse features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
pshy.require("pshy.tfm_emulator.environment.tfm_settings")



--- Members:
pshy.tfm_emulator_player_bound_keys = {}
pshy.tfm_emulator_player_bound_mice = {}



--- Internal Use:
local bound_keys = pshy.tfm_emulator_player_bound_keys
local bound_mice = pshy.tfm_emulator_player_bound_mice
local lua_print = pshy.lua_print
local lua_string_format = pshy.lua_string_format



--- Simulate a player mouse click.
-- This have no effect if the player mouse is not bound.
function pshy.tfm_emulator_Keyboard(player_name, keycode, down, x, y)
	if eventKeyboard then
		if down == nil then
			down = true
		end
		if bound_keys[player_name] and bound_keys[player_name][keycode] and bound_keys[player_name][keycode][down and 1 or 2] then
			x = x or 400
			y = y or 200
			if pshy.tfm_emulator_log_events then
				lua_print(lua_string_format(">> eventKeyboard(%s, %d, %s, %d, %d)", player_name, keycode, tostring(down), x, y))
			end
			eventKeyboard(player_name, keycode, down, x, y)
		end
	end
end



--- Reimplementation of `system.bindKeyboard`.
system.bindKeyboard = function(player_name, keycode, down, yes)
	if not bound_keys[player_name] then
		bound_keys[player_name] = {}
	end
	if not bound_keys[player_name][keycode] then
		bound_keys[player_name][keycode] = {}
	end
	bound_keys[player_name][keycode][down and 1 or 2] = yes
end
tfm.exec.bindKeyboard = system.bindKeyboard



--- Simulate a player key press.
-- This have no effect if the player key is not bound.
function pshy.tfm_emulator_Mouse(player_name, x, y)
	if eventMouse then
		if bound_mice[player_name] then
			x = x or 400
			y = y or 200
			if pshy.tfm_emulator_log_events then
				lua_print(lua_string_format(">> eventMouse(%s, %d, %d)", player_name, x, y))
			end
			eventMouse(player_name, x, y)
		end
	end
end



--- Reimplementation of `system.bindMouse`.
system.bindMouse = function(player_name, yes)
	bound_mice[player_name] = yes
end



--- Simulate a chat message (and a command if appropriate).
function pshy.tfm_emulator_ChatMessage(player_name, message)
	if eventChatMessage then
		if pshy.tfm_emulator_log_events then
			lua_print(lua_string_format(">> eventChatMessage(%s, %s)", player_name, message))
		end
		eventChatMessage(player_name)
	end
	if string.sub(message, 1, 1) == "!" then
		local command = string.sub(message, 2)
		if pshy.tfm_emulator_tfm_chat_commands_display then
			if not pshy.tfm_emulator_tfm_disabled_commands_display[command] then
				lua_print(lua_string_format("#room:  [%s]: %s", player_name, message))
			end
		end
		if eventChatCommand then
			if pshy.tfm_emulator_log_events then
				lua_print(lua_string_format(">> eventChatCommand(%s, %s)", player_name, command))
			end
			eventChatCommand(player_name, command)
		end
	else
		lua_print(lua_string_format("#room:  [%s]: %s", player_name, message))
	end
end
