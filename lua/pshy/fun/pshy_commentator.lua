--- pshy_commentator.lua
--
-- Made for racing, a bot commenting the game.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
--
-- @require pshy_merge.lua
pshy = pshy or {}



--- Module Settings:
pshy.commentator_prefix = "<vi>[Commentator]</vi>"



--- Internal use:
local counter_timers = {}
local first = true



--- `tfm.exec.newGame` override.
local original_NewGame = tfm.exec.newGame
local function NewGame(...)
	tfm.exec.chatMessage(string.format("%s <n>Changing map...", pshy.commentator_prefix))
	original_NewGame(...)
end
tfm.exec.newGame = NewGame



--- Callback for new game counter timers.
local function CounterTimerCallback(timer_id, text, index)
	tfm.exec.chatMessage(text)
	counter_timers[index] = nil
end



function eventNewGame()
	tfm.exec.chatMessage(string.format("%s 3<n>...", pshy.commentator_prefix))
	for i_timer, id in ipairs(counter_timers) do
		system.removeTimer(id)
	end
	counter_timers = {}
	counter_timers[3] = tfm.exec.newTimer(CounterTimerCallback, 1000, false, string.format("%s 2<n>...", pshy.commentator_prefix), 3)
	counter_timers[2] = tfm.exec.newTimer(CounterTimerCallback, 2000, false, string.format("%s 1<n>...", pshy.commentator_prefix), 2)
	counter_timers[1] = tfm.exec.newTimer(CounterTimerCallback, 3000, false, string.format("%s <n>Go!", pshy.commentator_prefix), 1)
	first = false
end



function eventPlayerWon(player_name, time_elapsed)
	if not first then
		tfm.exec.chatMessage(string.format("%s <n>Congratulations to <vi>%s</vi> with a time of <vi>%fs</vi>!", pshy.commentator_prefix, player_name, time_elapsed / 1000))
	end
	first = true
end
