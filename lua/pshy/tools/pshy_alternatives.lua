--- pshy_alternatives.lua
--
-- Allow some scripts using restricted lua features to still work when those are not available.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_commands.lua
-- @require pshy_merge.lua
-- @require pshy_print.lua
--
-- @require_priority WRAPPER
pshy = pshy or {}



--- Help page:
pshy.help_pages = pshy.help_pages or {}				-- touching the help_pages table
pshy.help_pages["pshy_alternatives"] = {title = "LUA Features Alternatives", text = "Allow some scripts to run without all lua features.\n", commands = {}}



--- Module Settings:
pshy.alternatives_chat_arbitrary_id = 84
local have_sync_access = (tfm.exec.getPlayerSync() ~= nil)		-- currently defined in `pshy_perms.lua`, true when funcorp features are available



--- Internal Use:
pshy.commands = pshy.commands or {}						-- touching the commands table
pshy.alternatives_chatMessage = tfm.exec.chatMessage		-- original chatMessage function
pshy.alternatives_players_chats = {}						-- stores the last messages sent per player with nofuncorp_chatMessage
pshy.alternatives_players_hidden_chats = {}				-- status of chats
pshy.alternatives_last_loop_time = 0						-- replacement for game timers
pshy.alternatives_timers = {}								-- replacement for game timers



--- Get a nofuncorp player's chat content.
function pshy.alternatives_GetPlayerChatContent(player_name)
	local chat = pshy.alternatives_players_chats[player_name]
	local total = ""
	for i_line, line in ipairs(chat) do
		total = "<n>" .. total .. line .. "</n>\n"
	end
	return total
end



--- Update a nofuncorp player's chat.
function pshy.alternatives_UpdatePlayerChat(player_name)
	if not pshy.alternatives_players_hidden_chats[player_name] then
		local text = pshy.alternatives_GetPlayerChatContent(player_name)
		ui.addTextArea(pshy.alternatives_chat_arbitrary_id, text, player_name, 0, 50, 400, nil, 0x0, 0x0, 1.0, true)
	else
		ui.removeTextArea(pshy.alternatives_chat_arbitrary_id, player_name)
	end
end



--- Replacement for `tfm.exec.chatMessage`.
-- @TODO: only remove older chat messages if required.
function pshy.alternatives_chatMessage(message, player_name)
	-- convert message
	if type(message) ~= "string" then
		message = tostring(message)
	end
	-- params checks
	if #message > 200 then
		print_error("<fc>[Alt]</fc> chatMessage: message length is limited to 200!")
		return
	end
	-- nil player value
	if not player_name then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.alternatives_chatMessage(message, player_name)
		end
		return
	end
	-- add message
	pshy.alternatives_players_chats[player_name] = pshy.alternatives_players_chats[player_name] or {}
	local chat = pshy.alternatives_players_chats[player_name]
	if #chat > 8 then
		table.remove(chat, 1)
	end
	table.insert(chat, message)
	-- display
	pshy.alternatives_UpdatePlayerChat(player_name)
end



--- Replacement for `system.addTimer`.
-- @todo Test this.
function pshy.alternatives_newTimer(callback, time, loop, arg1, arg2, arg3, arg4)
	-- params checks
	if time < 1000 then
		print_error("<fc>[Alt]</fc> newTimer: minimum time is 1000!")
		return
	end
	-- find an id
	local timer_id = 1
	while pshy.alternatives_timers[timer_id] do
		timer_id = timer_id + 1
	end
	-- create
	pshy.alternatives_timers[timer_id] = {}
	timer = pshy.alternatives_timers[timer_id]
	timer.timer_id = timer_id
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
function pshy.alternatives_removeTimer(timer_id)
	pshy.alternatives_timers[timer_id] = nil
end



--- Replacement for `tfm.exec.getPlayerSync`.
-- Yes, the return is wrong, the goal is only to let modules work without spamming the log.
function pshy.alternatives_getPlayerSync()
	return pshy.loader
end



--- TFM event eventNewGame
function eventNewGame()
	if not have_sync_access then
		for i_timer,timer in pairs(pshy.alternatives_timers) do
			timer.next_run_time = timer.next_run_time - pshy.alternatives_last_loop_time
		end
		pshy.alternatives_last_loop_time = 0
	end
end



--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	if not have_sync_access then
		pshy.alternatives_last_loop_time = time
		local ended_timers = {}
		for i_timer, timer in pairs(pshy.alternatives_timers) do
			if timer.next_run_time < time then
				timer.callback(timer.timer_id, timer.arg1, timer.arg2, timer.arg3, timer.arg4)
				if timer.loop then
					timer.next_run_time = timer.next_run_time + timer.time
				else
					ended_timers[i_timer] = true
				end
			end
		end
		for i_ended_timer in pairs(ended_timers) do
			pshy.alternatives_timers[i_ended_timer] = nil
		end
	end
end



--- !chat
local function ChatCommandChat(user)
	pshy.alternatives_players_hidden_chats[user] = not pshy.alternatives_players_hidden_chats[user]
	pshy.alternatives_UpdatePlayerChat(user)
	return true
end
pshy.commands["chat"] = {func = ChatCommandChat, desc = "toggle the alternative chat", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_alternatives"].commands["chat"] = pshy.commands["chat"]
pshy.perms.everyone["!chat"] = true



--- Initialization:
function eventInit()
	if not have_sync_access then
		tfm.exec.chatMessage = pshy.alternatives_chatMessage
		system.newTimer = pshy.alternatives_newTimer
		system.removeTimer = pshy.alternatives_removeTimer
		tfm.exec.removeTimer = pshy.alternatives_removeTimer
		tfm.exec.getPlayerSync = pshy.alternatives_getPlayerSync
		tfm.exec.chatMessage("This text area is replacing tfm.exec.chatMessage().")
		tfm.exec.chatMessage("Type <ch2>!chat</ch2> to toggle this text.")
	end
end
