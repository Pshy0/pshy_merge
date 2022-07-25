--- pshy.tools.motd
--
-- Add announcement features.
--
--	!setmotd <join_message>		- Set a message for joining players.
--	!motd						- See the current motd.
--	!announce <message>			- Send an orange message.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
pshy.require("pshy.events")
local help_pages = pshy.require("pshy.help.pages")



--- Namespace.
local motd = {}



--- Module settings:
motd.message = nil		-- The message to display to joining players.
motd.every = -1			-- Every how many chat messages to display the motd.



--- Module Help Page:
help_pages["pshy_motd"] = {back = "pshy", title = "Announcements", text = "This module adds announcement features.\nThis include a MOTD displayed to joining players.\n", examples = {}}
help_pages["pshy_motd"].commands = {}
help_pages["pshy"].subpages["pshy_motd"] = help_pages["pshy_motd"]



--- Internal use.
local message_count_since_motd = 0



--- !setmotd <join_message>
-- Set the motd (or html).
local function ChatCommandSetmotd(user, message)
	if string.sub(message, 1, 1) == "&" then
		motd.message = string.gsub(string.gsub(message, "&lt;", "<"), "&gt;", ">")
	else
		motd.message = "<fc>" .. message .. "</fc>"
	end
	return ChatCommandMotd(user)
end
command_list["setmotd"] = {perms = "admins", func = ChatCommandSetmotd, desc = "Set the motd (support html).", argc_min = 1, argc_max = 1, arg_types = {"string"}}
command_list["setmotd"].help = "You may also use html /!\\ BUT CLOSE MARKUPS!\n"
help_pages["pshy_motd"].commands["setmotd"] = command_list["setmotd"]



--- !motd
-- See the current motd.
local function ChatCommandMotd(user)
	if motd.message then
		return true, string.format("Current motd:\n%s", motd.message)
	else
		return false, "No MOTD set. Use `!setmotd <motd>` to set one."
	end
end
command_list["motd"] = {perms = "everyone", func = ChatCommandMotd, desc = "See the current motd.", argc_min = 0, argc_max = 0, arg_types = {}}
help_pages["pshy_motd"].commands["motd"] = command_list["motd"]



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
command_list["announce"] = {perms = "admins", func = ChatCommandAnnounce, desc = "Send an orange message in the chat (support html).", argc_min = 1, argc_max = 1, arg_types = {"string"}}
command_list["announce"].help = "You may also use html /!\\ BUT CLOSE MARKUPS!\n"
help_pages["pshy_motd"].commands["announce"] = command_list["announce"]



--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if motd.message then
		tfm.exec.chatMessage(motd.message, player_name)
	end
end



--- TFM event eventChatMessage
function eventChatMessage(player_name, message)
	if motd.message and motd.every > 0 then
		message_count_since_motd = message_count_since_motd + 1
		if message_count_since_motd >= motd.every then
			tfm.exec.chatMessage(motd.message, nil)
			message_count_since_motd = 0
		end
	end
end



return motd
