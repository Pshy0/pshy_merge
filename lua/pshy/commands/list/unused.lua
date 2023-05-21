--- pshy.commands.list.unused
--
-- Rarely used commands that have been moved from other modules to save space.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local commands = pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
pshy.require("pshy.utils.lua")
pshy.require("pshy.utils.print")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "Unused", title = "Unused commands.", text = ""}
help_pages[__MODULE_NAME__].commands = {}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- !rejoin [player]
-- Simulate a rejoin.
local function ChatCommandRejoin(user, target)
	target = target or user
	tfm.exec.killPlayer(target)
	eventPlayerLeft(target)
	eventNewPlayer(target)
	return true, "Simulating a rejoin..."
end
command_list["rejoin"] = {perms = "admins", func = ChatCommandRejoin, desc = "simulate a rejoin (events left + join + died)", argc_min = 0, argc_max = 1, arg_types = {"string"}}
help_pages[__MODULE_NAME__].commands["rejoin"] = command_list["rejoin"]



--- !runas command
-- Run a command as another player (use the other player's permissions).
local function ChatCommandRunas(player_name, target_player, command)
	print_warn("Player %s running command as %s: %s", player_name, target_player, command)
	commands.Run(target_player, command)
end
command_list["runas"] = {func = ChatCommandRunas, desc = "run a command as another player", argc_min = 2, argc_max = 2, arg_types = {"player", "string"}}
help_pages[__MODULE_NAME__].commands["runas"] = command_list["runas"]



--- !luaversion
local function ChatCommandLuaversion(user)
	if type(_VERSION) == "string" then
		return true, string.format("LUA version: %s", tostring(_VERSION))
	else
		return false, "LUA not properly implemented."
	end
end
command_list["luaversion"] = {perms = "everyone", func = ChatCommandLuaversion, desc = "Show LUA's version.", argc_min = 0, argc_max = 0}
help_pages[__MODULE_NAME__].commands["luaversion"] = command_list["luaversion"]



--- !jitversion
local function ChatCommandJitversion(user)
	if type(jit) == "table" then
		return true, string.format("LUA JIT version: %s", tostring(jit.version))
	else
		return false, "JIT not used or not properly implemented."
	end
end
command_list["jitversion"] = {perms = "everyone", func = ChatCommandJitversion, desc = "Show JIT's version.", argc_min = 0, argc_max = 0}
help_pages[__MODULE_NAME__].commands["jitversion"] = command_list["jitversion"]
