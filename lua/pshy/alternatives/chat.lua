--- pshy.alternatives.chat
--
-- Adds chat for scripts ran in tribehouse.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
pshy.require("pshy.utils.print")
local help_pages = pshy.require("pshy.help.pages")
local command_list = pshy.require("pshy.commands.list")



--- Namespace:
local alternative_chat = {}


--- Help page:
help_pages["pshy_alternatives"] = {title = "LUA Features Alternatives", text = "Allow some scripts to run without all lua features.\n", commands = {}}



--- Module Settings:
alternative_chat.chat_arbitrary_id = 84



--- Internal use:
local have_sync_access = (tfm.exec.getPlayerSync() ~= nil)
local players_chats = {}									-- stores the last messages sent per player
local players_hidden_chats = {}								-- status of chats



--- Get an alternative player's chat content.
local function GetPlayerChatContent(player_name)
	local chat = players_chats[player_name]
	local total = ""
	for i_line, line in ipairs(chat) do
		total = "<n>" .. total .. line .. "</n>\n"
	end
	return total
end



--- Update an alternative player's chat.
local function UpdatePlayerChat(player_name)
	if not players_hidden_chats[player_name] then
		local text = GetPlayerChatContent(player_name)
		ui.addTextArea(alternative_chat.chat_arbitrary_id, text, player_name, 0, 50, 400, nil, 0x0, 0x0, 1.0, true)
	else
		ui.removeTextArea(alternative_chat.chat_arbitrary_id, player_name)
	end
end



--- Replacement for `tfm.exec.chatMessage`.
-- @TODO: only remove older chat messages if required.
local function chatMessage(message, player_name)
	-- convert message
	if type(message) ~= "string" then
		message = tostring(message)
	end
	-- replace http and ://
	message = message:gsub("http", "ht&#116;ps"):gsub("://", ":&#47;/")
	-- params checks
	if #message > 200 then
		print_error("<fc>[Alt]</fc> chatMessage: message length is limited to 200!")
		return
	end
	-- nil player value
	if not player_name then
		for player_name in pairs(tfm.get.room.playerList) do
			chatMessage(message, player_name)
		end
		return
	end
	-- add message
	players_chats[player_name] = players_chats[player_name] or {}
	local chat = players_chats[player_name]
	if #chat > 8 then
		table.remove(chat, 1)
	end
	table.insert(chat, message)
	-- display
	UpdatePlayerChat(player_name)
end



--- !chat
local function ChatCommandChat(user)
	players_hidden_chats[user] = not players_hidden_chats[user]
	UpdatePlayerChat(user)
	return true
end
command_list["chat"] = {perms = "everyone", func = ChatCommandChat, desc = "toggle the alternative chat", argc_min = 0, argc_max = 0}
help_pages["pshy_alternatives"].commands["chat"] = command_list["chat"]



function eventInit()
	if not have_sync_access then
		tfm.exec.chatMessage = chatMessage
		chatMessage("This text area is replacing tfm.exec.chatMessage().")
		chatMessage("Type <ch2>!chat</ch2> to toggle this text.")
	end
end



return alternative_chat
