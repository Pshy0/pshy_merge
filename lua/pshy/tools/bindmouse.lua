--- pshy.tools.bindmouse
--
-- Bind your mouse to a command.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.events")



--- Module Help Page:
pshy.help_pages["pshy_bindmouse"] = {back = "pshy", title = "Mouse Binds", text = "Bind a command to your mouse (use $d and $d for x and y)\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_bindmouse"] = pshy.help_pages["pshy_bindmouse"]



--- Internal use:
pshy.bindmouse_players_bind = {}



--- TFM event eventMouse.
function eventMouse(player_name, x, y)
	if pshy.bindmouse_players_bind[player_name] then
		local cmd = string.format(pshy.bindmouse_players_bind[player_name], x, y) -- only in Lua!
		eventChatCommand(player_name, cmd)
		return false
	end
end



--- !bindmouse [command]
function pshy.bindmouse_ChatCommandMousebind(user, command)
	if command == nil then
		pshy.bindmouse_players_bind[user] = nil
		tfm.exec.chatMessage("Mouse bind disabled.", user)
	else
		if string.sub(command, 1, 1) == "!" then
			command = string.sub(command, 2, #command)
		end
		pshy.bindmouse_players_bind[user] = command
		tfm.exec.chatMessage("Mouse bound to `" .. command .. "`.", user)
		system.bindMouse(user, true)
	end
end
pshy.commands["bindmouse"] = {perms = "admins", func = pshy.bindmouse_ChatCommandMousebind, desc = "bind a command to your mouse, use %d and %d for coordinates", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"command"}}
pshy.help_pages["pshy_bindmouse"].commands["bindmouse"] = pshy.commands["bindmouse"]
