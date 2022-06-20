--- pshy.tools.motd
--
-- Add announcement features.
--
--	!setmotd <join_message>		- Set a message for joining players.
--	!motd						- See the current motd.
--	!announce <message>			- Send an orange message.
--	!luaset pshy.motd_every <n> - Repeat the motd every n messages.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.doc")
pshy.require("pshy.bases.events")



--- Module settings:
pshy.motd = nil			-- The message to display to joining players.
pshy.motd_every = -1			-- Every how many chat messages to display the motd.



--- Module Help Page:
pshy.help_pages["pshy_motd"] = {back = "pshy", title = "MOTD / Announcements", text = "This module adds announcement features.\nThis include a MOTD displayed to joining players.\n", examples = {}}
pshy.help_pages["pshy_motd"].commands = {}
pshy.help_pages["pshy_motd"].examples["luaset pshy.motd_every 100"] = "Show the motd to all players every 100 messages."
pshy.help_pages["pshy"].subpages["pshy_motd"] = pshy.help_pages["pshy_motd"]



--- Internal use.
pshy.message_count_since_motd = 0



--- !setmotd <join_message>
-- Set the motd (or html).
local function ChatCommandSetmotd(user, message)
	if string.sub(message, 1, 1) == "&" then
		pshy.motd = string.gsub(string.gsub(message, "&lt;", "<"), "&gt;", ">")
	else
		pshy.motd = "<fc>" .. message .. "</fc>"
	end
	return ChatCommandMotd(user)
end
pshy.commands["setmotd"] = {perms = "admins", func = ChatCommandSetmotd, desc = "Set the motd (support html).", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.commands["setmotd"].help = "You may also use html /!\\ BUT CLOSE MARKUPS!\n"
pshy.help_pages["pshy_motd"].commands["setmotd"] = pshy.commands["setmotd"]



--- !motd
-- See the current motd.
local function ChatCommandMotd(user)
	if pshy.motd then
		return true, string.format("Current motd:\n%s", pshy.motd)
	else
		return false, "No MOTD set. Use `!setmotd <motd>` to set one."
	end
end
pshy.commands["motd"] = {perms = "everyone", func = ChatCommandMotd, desc = "See the current motd.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_motd"].commands["motd"] = pshy.commands["motd"]



--- !announce <message>
-- Send an orange message (or html).
local function ChatCommandAnnounce(player_name, message)
	if string.sub(message, 1, 1) == "&" then
		tfm.exec.chatMessage(string.gsub(string.gsub(message, "&lt;", "<"), "&gt;", ">"), nil)
	else
		tfm.exec.chatMessage("<fc>" .. message .. "</fc>", nil)
	end
	-- <r><bv><bl><j><vp>
	return true
end
pshy.commands["announce"] = {perms = "admins", func = ChatCommandAnnounce, desc = "Send an orange message in the chat (support html).", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.commands["announce"].help = "You may also use html /!\\ BUT CLOSE MARKUPS!\n"
pshy.help_pages["pshy_motd"].commands["announce"] = pshy.commands["announce"]



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if pshy.motd then
		tfm.exec.chatMessage(pshy.motd, player_name)
	end
end



--- TFM event eventChatMessage
function eventChatMessage(player_name, message)
	if pshy.motd and pshy.motd_every > 0 then
		pshy.message_count_since_motd = pshy.message_count_since_motd + 1
		if pshy.message_count_since_motd >= pshy.motd_every then
			tfm.exec.chatMessage(pshy.motd, nil)
			pshy.message_count_since_motd = 0
		end
	end
end
