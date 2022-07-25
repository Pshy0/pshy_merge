--- pshy.commands.list.rp
--
-- Add commands to send formated chat messages.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
local perms = pshy.require("pshy.perms")



--- Module Help Page:
help_pages["pshy_commands_rp"] = {back = "pshy", title = "Msg", text = "Adds message commands.\n", commands = {}}
help_pages["pshy"].subpages["pshy_commands_rp"] = help_pages["pshy_commands_fun"]



--- !action
local function ChatCommandAction(user, action)
	tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
	return true
end 
command_list["action"] = {perms = "admins", func = ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_rp"].commands["action"] = command_list["action"]



--- !say
local function ChatCommandSay(user, message)
	tfm.exec.chatMessage("<v>[" .. user .. "]</v> <n>" .. message .. "</n>")
	return true
end 
command_list["say"] = {perms = "admins", func = ChatCommandSay, desc = "say something", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_rp"].commands["say"] = command_list["say"]
