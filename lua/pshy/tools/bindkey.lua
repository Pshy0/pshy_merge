--- pshy.tools.bindkey
--
-- Bind your keys to a command.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local keycodes = pshy.require("pshy.enums.keycodes")



--- Module Help Page:
help_pages["pshy_bindkey"] = {back = "pshy", title = "Key Binds", text = "Bind a command to a key (use %d and %d for x and y)\n", commands = {}}
help_pages["pshy"].subpages["pshy_bindkey"] = help_pages["pshy_bindkey"]



--- Namespace.
local bindkey = {}



--- Internal use:
local bindkey_players_binds = {}			-- players binds



--- TFM event eventKeyboard.
function eventKeyboard(player_name, key_code, down, x, y)
	if down and bindkey_players_binds[player_name] then
		local binds = bindkey_players_binds[player_name]
		if binds[key_code] then
			local cmd = string.format(binds[key_code], x, y) -- only in Lua!
			eventChatCommand(player_name, cmd)
			return false
		end
	end
end



--- !bindkey <key> [command]
local function ChatCommandBindkey(user, keyname, command)
	if not keyname then
		bindkey_players_binds[user] = nil
		return true, "Deleted key binds."
	end
	keycode = tonumber(keyname)
	if not keycode then
		keycode = keycodes[keyname]
	end
	if not keycode then
		return false, "unknown key, use the KEY_NAME ('A', 'SLASH', 'NUMPAD_ADD', ...)"
	end
	bindkey_players_binds[user] = bindkey_players_binds[user] or {}
	local binds = bindkey_players_binds[user]
	if command == nil then
		binds[keycode] = nil
		tfm.exec.chatMessage("Key bind removed.", user)
	else
		if string.sub(command, 1, 1) == "!" then
			command = string.sub(command, 2, #command)
		end
		binds[keycode] = command
		tfm.exec.chatMessage("Key bound to `" .. command .. "`.", user)
		tfm.exec.bindKeyboard(user, keycode, true, true)
	end
end
command_list["bindkey"] = {perms = "admins", func = ChatCommandBindkey, desc = "bind a command to a key, use $d and $d for coordinates", argc_min = 0, argc_max = 2, arg_types = {"string", "string"}, arg_names = {"KEYNAME", "command"}}
help_pages["pshy_bindkey"].commands["bindkey"] = command_list["bindkey"]



return bindkey
