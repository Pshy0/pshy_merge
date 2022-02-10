--- pshy_adminchat.lua
--
-- Add a room admin chat.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--
-- @require_priority ANTICHEAT



--- Module Help Page:
pshy.help_pages["pshy_adminchat"] = {back = "pshy", title = "Admin Chat", text = "Chat for room admins", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_adminchat"] = pshy.help_pages["pshy_adminchat"]



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
	for admin in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>⚔ [" .. user .. "] <ch2>" .. message, admin)
	end
	return true
end
pshy.commands["adminchat"] = {func = ChatCommandAdminchat, desc = "send a message to room admins", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"room-admin-only message"}}
pshy.help_pages["pshy_adminchat"].commands["adminchat"] = pshy.commands["adminchat"]
pshy.perms.admins["!adminchat"] = true
pshy.commands_aliases["ac"] = "adminchat"
