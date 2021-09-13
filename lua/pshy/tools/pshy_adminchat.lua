--- pshy_adminchat.lua
--
-- Add an admin chat.
--
-- @author Pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua



--- Module Help Page:
pshy.help_pages["pshy_adminchat"] = {back = "pshy", title = "Admin Chat", text = "Chat for room admins", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_adminchat"] = pshy.help_pages["pshy_adminchat"]



--- !adminchat
function pshy.ChatCommandAdminchat(user, message)
	for admin in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>⚔ [" .. user .. "] <ch2>" .. message, admin)
	end
end
pshy.chat_commands["adminchat"] = {func = pshy.ChatCommandAdminchat, desc = "send a message to room admins", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"room-admin-only message"}}
pshy.help_pages["pshy_adminchat"].commands["adminchat"] = pshy.chat_commands["adminchat"]
pshy.perms.admins["!adminchat"] = true
pshy.commands_aliases["ac"] = "adminchat"
