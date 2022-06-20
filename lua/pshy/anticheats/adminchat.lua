--- pshy.anticheats.adminchat
--
-- Add an `!ac` command to send a message to room admins.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.events")
pshy.require("pshy.bases.perms")



--- Module Help Page:
pshy.help_pages["pshy_adminchat"] = {back = "pshy", restricted = true, title = "Admin Chat", text = "Chat for room admins", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_adminchat"] = pshy.help_pages["pshy_adminchat"]



local displayed_admin_disclaimers = {}		-- set of admins who have been shown the command disclaimer



--- Send a message to room admins.
function pshy.adminchat_Message(origin, message)
	if not message then
		message = origin
		origin = "SCRIPT"
	end
	for admin in pairs(pshy.admins) do
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
	for admin in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>⚔ [" .. user .. "] <ch2>" .. message, admin)
		if not displayed_admin_disclaimers[admin] == true then
			tfm.exec.chatMessage("<r>⚔ <o>Use `<r>!ac <message></r>` to send a message to other room admins.", admin)
			displayed_admin_disclaimers[admin] = true
		end
	end
	return true
end
pshy.commands["adminchat"] = {aliases = {"ac"}, perms = "admins", func = ChatCommandAdminchat, desc = "send a message to room admins", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"room-admin-only message"}}
pshy.help_pages["pshy_adminchat"].commands["adminchat"] = pshy.commands["adminchat"]
