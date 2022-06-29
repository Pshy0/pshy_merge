--- pshy.tfm_emulator.controls
--
-- Simulate keyboard & mouse features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
pshy.require("pshy.tfm_emulator.environment.tfm_settings")
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Members:
tfmenv.player_bound_keys = {}
tfmenv.player_bound_mice = {}



--- Internal Use:
local bound_keys = tfmenv.player_bound_keys
local bound_mice = tfmenv.player_bound_mice
local lua_print = print
local lua_string_format = string.format



--- Simulate a player mouse click.
-- This have no effect if the player mouse is not bound.
function tfmenv.Keyboard(player_name, keycode, down, x, y)
	if tfmenv.env.eventKeyboard then
		if down == nil then
			down = true
		end
		if bound_keys[player_name] and bound_keys[player_name][keycode] and bound_keys[player_name][keycode][down and 1 or 2] then
			x = x or 400
			y = y or 200
			tfmenv.CallEvent("eventKeyboard", player_name, keycode, down, x, y)
		end
	end
end



--- Reimplementation of `system.bindKeyboard`.
tfmenv.env.system.bindKeyboard = function(player_name, keycode, down, yes)
	if not bound_keys[player_name] then
		bound_keys[player_name] = {}
	end
	if not bound_keys[player_name][keycode] then
		bound_keys[player_name][keycode] = {}
	end
	bound_keys[player_name][keycode][down and 1 or 2] = yes
end
tfmenv.env.tfm.exec.bindKeyboard = tfmenv.env.system.bindKeyboard



--- Simulate a player key press.
-- This have no effect if the player key is not bound.
function tfmenv.Mouse(player_name, x, y)
	if tfmenv.env.eventMouse then
		if bound_mice[player_name] then
			x = x or 400
			y = y or 200
			tfmenv.CallEvent("eventMouse", player_name, x, y)
		end
	end
end



--- Reimplementation of `system.bindMouse`.
tfmenv.env.system.bindMouse = function(player_name, yes)
	bound_mice[player_name] = yes
end



--- Simulate a chat message (and a command if appropriate).
function tfmenv.ChatMessage(player_name, message)
	tfmenv.CallEvent("eventChatMessage", player_name, message)
	if string.sub(message, 1, 1) == "!" then
		local command = string.sub(message, 2)
		if tfmenv.tfm_chat_commands_display then
			if not tfmenv.tfm_disabled_commands_display[command] then
				print(string.format("#room:  [%s]: %s", player_name, message))
			end
		end
		tfmenv.CallEvent("eventChatCommand", player_name, command)
	else
		print(string.format("#room:  [%s]: %s", player_name, message))
	end
end
