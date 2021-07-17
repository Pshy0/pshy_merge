--- pshy_nofuncorp.lua
--
-- Allow to still use some funcorp-only lua features in non-funcorp rooms.
-- Also works in tribehouse.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_perms.lua
-- @require pshy_commands.lua
pshy = pshy or {}



--- Help page:
pshy.help_pages = pshy.help_pages or {}				-- touching the help_pages table
pshy.help_pages["pshy_nofuncorp"] = {title = "No FunCorp Alternatives", text = "Allow some FunCorp only features to not prevent a module from running in non-funcorp rooms.\n", commands = {}}



--- Module Settings:
--pshy.funcorp = (tfm.exec.getPlayerSync() ~= nil)		-- currently defined in `pshy_perms.lua`, true when funcorp features are available
pshy.nofuncorp_chat_arbitrary_id = 14



--- Internal Use:
pshy.chat_commands = pshy.chat_commands or {}			-- touching the chat_commands table
pshy.nofuncorp_chatMessage = tfm.exec.chatMessage		-- original chatMessage function
pshy.nofuncorp_players_chats = {}						-- stores the last messages sent per player with nofuncorp_chatMessage
pshy.nofuncorp_players_hidden_chats = {}				-- status of chats



--- Get a nofuncorp player's chat content.
function pshy.nofuncorp_GetPlayerChatContent(player_name)
	local chat = pshy.nofuncorp_players_chats[player_name]
	local total = ""
	for i_line, line in ipairs(chat) do
		total = "<bl>" .. total .. line .. "</bl>\n"
	end
	return total
end



--- Update a nofuncorp player's chat.
function pshy.nofuncorp_UpdatePlayerChat(player_name)
	if not pshy.nofuncorp_players_hidden_chats[player_name] then
		local text = pshy.nofuncorp_GetPlayerChatContent(player_name)
		ui.addTextArea(pshy.nofuncorp_chat_arbitrary_id, text, player_name, 0, 20, 400, nil, 0x0, 0x0, 1.0, true)
	else
		ui.removeTextArea(pshy.nofuncorp_chat_arbitrary_id, player_name)
	end
end



--- Replacement for tfm.exec.chatMessage
function pshy.nofuncorp_chatMessage(message, player_name)
	-- params checks
	if #message > 200 then
		print("[PshyNoFuncorp] Error: message length is limited to 200!")
		return
	end
	-- nil player value
	if not player_name then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.nofuncorp_chatMessage(message, player_name)
		end
		return
	end
	-- add message
	pshy.nofuncorp_players_chats[player_name] = pshy.nofuncorp_players_chats[player_name] or {}
	local chat = pshy.nofuncorp_players_chats[player_name]
	if #chat > 8 then
		table.remove(chat, 1)
	end
	table.insert(chat, message)
	-- display
	pshy.nofuncorp_UpdatePlayerChat(player_name)
end



--- !chat
function pshy.nofuncorp_ChatCommandChat(user)
	pshy.nofuncorp_players_hidden_chats[user] = not pshy.nofuncorp_players_hidden_chats[user]
	pshy.nofuncorp_UpdatePlayerChat(user)
end
pshy.chat_commands["chat"] = {func = pshy.nofuncorp_ChatCommandChat, desc = "toggle the nofuncorp chat", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_nofuncorp"].commands["chat"] = pshy.chat_commands["chat"]



--- Initialization:
function eventInit()
	if not pshy.funcorp then
		tfm.exec.chatMessage = pshy.nofuncorp_chatMessage
		tfm.exec.chatMessage("[PshyNoFuncorp] Lua FunCorp features unavailable, replacing them.")
		tfm.exec.chatMessage("[PshyNoFuncorp] Type !chat to toggle this text.")
	end
end
