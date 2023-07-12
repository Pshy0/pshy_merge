--- pshy.commands.list.rp
--
-- Add commands to send formated chat messages.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")
local perms = pshy.require("pshy.perms")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Msg", text = "Adds message commands.\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages["pshy_commands_fun"]



__MODULE__.commands = {
	["action"] = {
		perms = "admins",
		desc = "send a rp-like/action message",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, action)
			tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
			return true
		end 
	},
	["say"] = {
		perms = "admins",
		desc = "say something",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, message)
			tfm.exec.chatMessage("<v>[" .. user .. "]</v> <n>" .. message .. "</n>")
			return true
		end 
	}
}
