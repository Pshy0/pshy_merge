--- pshy.commands.rp
--
-- Add commands to send formated chat messages.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")
local perms = pshy.require("pshy.perms")



--- Module Help Page:
help_pages["pshy_commands_rp"] = {back = "pshy", title = "RP", text = "Adds fun commands everyone can use.\n", commands = {}}
help_pages["pshy"].subpages["pshy_commands_rp"] = help_pages["pshy_commands_fun"]



--- !action
local function ChatCommandAction(user, action)
	tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
	return true
end 
pshy.commands["action"] = {perms = "admins", func = ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_rp"].commands["action"] = pshy.commands["action"]



--- !say
local function ChatCommandSay(user, message)
	tfm.exec.chatMessage("<v>[" .. user .. "]</v> <n>" .. message .. "</n>")
	return true
end 
pshy.commands["say"] = {perms = "everyone", func = ChatCommandSay, desc = "say something", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_rp"].commands["say"] = pshy.commands["say"]
