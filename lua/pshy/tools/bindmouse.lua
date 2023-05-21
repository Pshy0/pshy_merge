--- pshy.tools.bindmouse
--
-- Bind your mouse to a command.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Mouse Binds", text = "Bind a command to your mouse (use $d and $d for x and y)\n", commands = {}}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Namespace.
local bindmouse = {}



--- Internal use:
local players_bind = {}



--- TFM event eventMouse.
function eventMouse(player_name, x, y)
	if players_bind[player_name] then
		local cmd = string.format(players_bind[player_name], x, y) -- only in Lua!
		eventChatCommand(player_name, cmd)
		return false
	end
end



--- !bindmouse [command]
local function ChatCommandMousebind(user, command)
	if command == nil then
		players_bind[user] = nil
		tfm.exec.chatMessage("Mouse bind disabled.", user)
	else
		if string.sub(command, 1, 1) == "!" then
			command = string.sub(command, 2, #command)
		end
		players_bind[user] = command
		tfm.exec.chatMessage("Mouse bound to `" .. command .. "`.", user)
		system.bindMouse(user, true)
	end
end
command_list["bindmouse"] = {perms = "admins", func = ChatCommandMousebind, desc = "bind a command to your mouse, use %d and %d for coordinates", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"command"}}
help_pages[__MODULE_NAME__].commands["bindmouse"] = command_list["bindmouse"]



return bindmouse
