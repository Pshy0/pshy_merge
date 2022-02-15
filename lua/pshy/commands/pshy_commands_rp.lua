--- pshy_commands_rp.lua
--
-- Add commands to send formated chat messages.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--
-- @require_priority UTILS



--- Module Help Page:
pshy.help_pages["pshy_commands_rp"] = {back = "pshy", title = "Fun Commands", text = "Adds fun commands everyone can use.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_commands_rp"] = pshy.help_pages["pshy_commands_fun"]



--- !action
local function ChatCommandAction(user, action)
	tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
	return true
end 
pshy.commands["action"] = {func = ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_commands_rp"].commands["action"] = pshy.commands["action"]



--- !say
local function ChatCommandSay(user, message)
	tfm.exec.chatMessage("<v>[" .. user .. "]</v> <n>" .. message .. "</n>")
	return true
end 
pshy.commands["say"] = {func = ChatCommandSay, desc = "say something", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_commands_rp"].commands["say"] = pshy.commands["say"]
pshy.perms.everyone["!say"] = true
