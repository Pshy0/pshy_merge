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
pshy.nofuncorp_last_loop_time = 0						-- replacement for game timers
pshy.nofuncorp_timers = {}								-- replacement for game timers



--- Get a nofuncorp player's chat content.
function pshy.nofuncorp_GetPlayerChatContent(player_name)
	local chat = pshy.nofuncorp_players_chats[player_name]
	local total = ""
	for i_line, line in ipairs(chat) do
		total = "<n>" .. total .. line .. "</n>\n"
	end
	return total
end



--- Update a nofuncorp player's chat.
function pshy.nofuncorp_UpdatePlayerChat(player_name)
	if not pshy.nofuncorp_players_hidden_chats[player_name] then
		local text = pshy.nofuncorp_GetPlayerChatContent(player_name)
		ui.addTextArea(pshy.nofuncorp_chat_arbitrary_id, text, player_name, 0, 50, 400, nil, 0x0, 0x0, 1.0, true)
	else
		ui.removeTextArea(pshy.nofuncorp_chat_arbitrary_id, player_name)
	end
end



--- Replacement for `tfm.exec.chatMessage`.
-- @TODO: only remove older chat messages if required.
function pshy.nofuncorp_chatMessage(message, player_name)
	-- params checks
	if #message > 200 then
		print("<fc>[PshyNoFuncorp]</fc> chatMessage: Error: message length is limited to 200!")
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



--- Replacement for `system.addTimer`.
-- @todo Test this.
function pshy.nofuncorp_newTimer(callback, time, loop, arg1, arg2, arg3, arg4)
	-- params checks
	if time < 1000 then
		print("<fc>[PshyNoFuncorp]</fc> newTimer: Error: minimum time is 1000!")
		return
	end
	-- find an id
	local timer_id = 1
	while pshy.nofuncorp_timers[timer_id] do
		timer_id = timer_id + 1
	end
	-- create
	pshy.nofuncorp_timers[timer_id] = {}
	timer = pshy.nofuncorp_timers[timer_id]
	timer.callback = callback
	timer.time = time
	timer.loop = loop
	timer.arg1 = arg1
	timer.arg2 = arg2
	timer.arg3 = arg3
	timer.arg4 = arg4
	timer.next_run_time = 0 + timer.time
	return timer_id
end



--- Replacement for `system.removeTimer`.
function pshy.nofuncorp_removeTimer(timer_id)
	pshy.nofuncorm_timers[timer_id] = nil
end



--- Replacement for `tfm.exec.getPlayerSync`.
-- Yes, the return is wrong, the goal is only to let modules work without spamming the log.
function pshy.nofuncorp_getPlayerSync()
	return pshy.loader
end



--- !chat
function pshy.nofuncorp_ChatCommandChat(user)
	pshy.nofuncorp_players_hidden_chats[user] = not pshy.nofuncorp_players_hidden_chats[user]
	pshy.nofuncorp_UpdatePlayerChat(user)
end
pshy.chat_commands["chat"] = {func = pshy.nofuncorp_ChatCommandChat, desc = "toggle the nofuncorp chat", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_nofuncorp"].commands["chat"] = pshy.chat_commands["chat"]
pshy.perms.everyone["!chat"] = true



--- TFM event eventNewGame
function eventNewGame()
	if not pshy.funcorp then
		for i_timer,timer in pairs(pshy.nofuncorp_timers) do
			timer.next_run_time = timer.next_run_time - pshy.nofuncorp_last_loop_time
		end
		pshy.nofuncorp_last_loop_time = 0
	end
end



--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	if not pshy.funcorp then
		pshy.nofuncorp_last_loop_time = time
		local ended_timers = {}
		for i_timer, timer in pairs(pshy.nofuncorp_timers) do
			if timer.next_run_time < time then
				timer.callback(timer.arg1, timer.arg2, timer.arg3, timer.arg4)
				if timer.loop then
					timer.next_run_time = timer.next_run_time + timer.time
				else
					ended_timers[i_timer] = true
				end
			end
		end
		for i_ended_timer in pairs(ended_timers) do
			pshy.nofuncorp_timers[i_ended_timer] = nil
		end
	end
end



--- Initialization:
function eventInit()
	if not pshy.funcorp then
		tfm.exec.chatMessage = pshy.nofuncorp_chatMessage
		system.newTimer = pshy.nofuncorp_newTimer
		system.removeTimer = pshy.nofuncorp_removeTimer
		tfm.exec.removeTimer = pshy.nofuncorp_removeTimer
		tfm.exec.getPlayerSync = pshy.nofuncorp_getPlayerSync
		tfm.exec.chatMessage("<fc>[PshyNoFuncorp]</fc> Lua chat messages unavailable, replacing them.")
		tfm.exec.chatMessage("<fc>[PshyNoFuncorp]</fc> Type <ch2>!chat</ch2> to toggle this text.")
	end
end
