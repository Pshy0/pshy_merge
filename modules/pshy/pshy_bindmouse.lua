--- pshy_bindmouse.lua
--
-- Bind your mouse to a command.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua



--- Module Help Page:
pshy.help_pages["pshy_bindmouse"] = {back = "pshy", title = "Mouse Binds", text = "Bind a command to your mouse (use $d and $d for x and y)\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_bindmouse"] = pshy.help_pages["pshy_bindmouse"]



--- Internal use:
pshy.bindmouse_players_bind = {}



--- TFM event eventMouse
function eventMouse(player_name, x, y)
	if pshy.bindmouse_players_bind[player_name] then
		local cmd = string.format(pshy.bindmouse_players_bind[player_name], x, y) -- only in Lua!
		eventChatCommand(cmd)
		return false
	end
end



--- !bindmouse [command]
function pshy.bindmouse_ChatCommandMousebind(user, command)
	if string.sub(command, 1, 1) == "!" then
		command = string.sub(command, 2, #command)
	end
	if command == nil then
		pshy.bindmouse_players_bind[user] = nil
		tfm.exec.chatMessage("Mouse bind disabled.", user)
	else
		pshy.bindmouse_players_bind[user] = command
		tfm.exec.chatMessage("Mouse bound to " .. command .. ".", user)
	end
end
pshy.chat_commands["bindmouse"] = {func = pshy.bindmouse_ChatCommandMousebind, desc = "bind a command to your mouse, use $d and $d for coordinates", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"command"}}
pshy.help_pages["pshy_bindmouse"].commands["bindmouse"] = pshy.chat_commands["bindmouse"]
pshy.perms.everyone["!bindmouse"] = true
