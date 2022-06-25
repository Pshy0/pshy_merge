--- pshy.anticheats.adminchat
--
-- Add an `!ac` command to send a message to room admins.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")
local perms = pshy.require("pshy.perms")



--- Module Help Page:
help_pages["pshy_adminchat"] = {back = "pshy", restricted = true, title = "Admin Chat", text = "Chat for room admins", commands = {}}
help_pages["pshy"].subpages["pshy_adminchat"] = help_pages["pshy_adminchat"]



local displayed_admin_disclaimers = {}		-- set of admins who have been shown the command disclaimer



--- Send a message to room admins.
function pshy.adminchat_Message(origin, message)
	if not message then
		message = origin
		origin = "SCRIPT"
	end
	for admin in pairs(perms.admins) do
		if origin then
			tfm.exec.chatMessage("<r>⚔ [" .. origin .. "] <o>" .. message, admin)
		else
			tfm.exec.chatMessage("<r>⚔ <o>" .. message, admin)
		end
	end
end



--- !adminchat
local function ChatCommandAdminchat(user, message)
	displayed_admin_disclaimers[user] = true
	for admin in pairs(perms.admins) do
		tfm.exec.chatMessage("<r>⚔ [" .. user .. "] <ch2>" .. message, admin)
		if not displayed_admin_disclaimers[admin] == true then
			tfm.exec.chatMessage("<r>⚔ <o>Use `<r>!ac <message></r>` to send a message to other room admins.", admin)
			displayed_admin_disclaimers[admin] = true
		end
	end
	return true
end
command_list["adminchat"] = {aliases = {"ac"}, perms = "admins", func = ChatCommandAdminchat, desc = "send a message to room admins", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"room-admin-only message"}}
help_pages["pshy_adminchat"].commands["adminchat"] = command_list["adminchat"]
